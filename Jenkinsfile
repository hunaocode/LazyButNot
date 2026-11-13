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

          stage('Xcode Build') {
              steps {
                  sh '''
                      set -e
                      set -o pipefail

                      mkdir -p build

                      xcodebuild \
                        -project "$PROJECT_PATH" \
                        -scheme "$SCHEME" \
                        -configuration Debug \
                        -destination 'generic/platform=iOS Simulator' \
                        -derivedDataPath "$DERIVED_DATA" \
                        CODE_SIGNING_ALLOWED=NO \
                        clean build 2>&1 | tee build/xcodebuild.log
                  '''
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
                  artifacts: 'build/**/*.log,build/**/*.xcresult/**',
                  allowEmptyArchive: true,
                  fingerprint: true
              )
          }

          cleanup {
              deleteDir()
          }
      }
  }