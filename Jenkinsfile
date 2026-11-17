pipeline {
      agent {
        label 'macos-ios'
      }

      options {
          skipDefaultCheckout(true)
          timestamps()
          timeout(time: 45, unit: 'MINUTES')
          disableConcurrentBuilds()

          buildDiscarder(logRotator(
              numToKeepStr: '5',
              artifactNumToKeepStr: '3'
          ))
      }

      environment {
          PROJECT_PATH = 'LazyButNot/LazyButNot.xcodeproj'
          SCHEME = 'LazyButNot'
          DERIVED_DATA = "${WORKSPACE}/build/DerivedData"
          TEST_DESTINATION = 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
      }

      stages {
          stage('Checkout') {
              steps {
                  checkout scm
              }
          }

          stage('Environment') {
              steps {
                  sh '''
                      set -e

                      echo "Jenkins workspace: $WORKSPACE"
                      sw_vers
                      uname -m
                      xcodebuild -version
                      python3 --version
                      git --version
                  '''
              }
          }

          stage('Localization Check') {
              steps {
                  sh '''
                      set -e

                      python3 scripts/i18n_check.py

                      git diff --exit-code -- \
                        LazyButNot/Localizable.xcstrings
                  '''
              }
          }

          stage('Tool Tests') {
              steps {
                  sh '''
                      set -e

                      python3 -m unittest discover \
                        -s toolchain/app_store_connect/tests \
                        -v
                  '''
              }
          }

          stage('Xcode Test') {
            steps {
                sh '''
                    set -e
                    set -o pipefail

                    mkdir -p build
                    rm -rf build/LazyButNotTests.xcresult

                    xcodebuild \
                        -project "$PROJECT_PATH" \
                        -scheme "$SCHEME" \
                        -configuration Debug \
                        -destination "$TEST_DESTINATION" \
                        -derivedDataPath "$DERIVED_DATA" \
                        -resultBundlePath build/LazyButNotTests.xcresult \
                        CODE_SIGNING_ALLOWED=NO \
                        clean test 2>&1 | tee build/xcode-test.log
                '''
            }
        }

          stage('Release Archive') {
              when {
                  anyOf {
                      branch 'main'
                      buildingTag()
                  }
              }

              steps {
                  sh '''
                      set -e
                      set -o pipefail

                      mkdir -p build

                      xcodebuild \
                        -project "$PROJECT_PATH" \
                        -scheme "$SCHEME" \
                        -configuration Release \
                        -destination 'generic/platform=iOS' \
                        -archivePath build/LazyButNot.xcarchive \
                        CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
                        clean archive 2>&1 | tee build/xcode-archive.log

                      xcodebuild \
                        -exportArchive \
                        -archivePath build/LazyButNot.xcarchive \
                        -exportPath build/export \
                        -exportOptionsPlist ci/ExportOptions.plist \
                        2>&1 | tee build/xcode-export.log
                  '''
              }
          }

          stage('Upload TestFlight') {
              when {
                  buildingTag()
              }

              steps {
                  withCredentials([
                      file(
                          credentialsId: 'asc-api-private-key',
                          variable: 'ASC_PRIVATE_KEY'
                      ),
                      string(
                          credentialsId: 'asc-api-key-id',
                          variable: 'ASC_KEY_ID'
                      ),
                      string(
                          credentialsId: 'asc-api-issuer-id',
                          variable: 'ASC_ISSUER_ID'
                      )
                  ]) {
                      sh '''
                          set -e

                          mkdir -p build/private_keys
                          install -m 600 \
                            "$ASC_PRIVATE_KEY" \
                            "build/private_keys/AuthKey_${ASC_KEY_ID}.p8"

                          export API_PRIVATE_KEYS_DIR="$WORKSPACE/build/private_keys"

                          IPA_PATH="$(find build/export -name '*.ipa' -type f -print -quit)"

                          if [ -z "$IPA_PATH" ]; then
                              echo "没有找到导出的 IPA"
                              exit 1
                          fi

                          xcrun altool \
                            --validate-app \
                            -f "$IPA_PATH" \
                            -t ios \
                            --api-key "$ASC_KEY_ID" \
                            --api-issuer "$ASC_ISSUER_ID"

                          xcrun altool \
                            --upload-app \
                            -f "$IPA_PATH" \
                            -t ios \
                            --api-key "$ASC_KEY_ID" \
                            --api-issuer "$ASC_ISSUER_ID"
                      '''
                  }
              }
          }
      }

      post {
          success {
              echo 'CI 构建成功'
          }

          failure {
              echo 'CI 构建失败，请查看失败阶段和 Console Output'
          }

          always {
              archiveArtifacts(
                  artifacts: 'build/**/*.log,build/**/*.xcresult/**,build/export/*.ipa,build/export/*.plist',
                  allowEmptyArchive: true,
                  fingerprint: true
              )
          }

          cleanup {
              deleteDir()
          }
      }
  }
