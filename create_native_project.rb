require 'fileutils'
require 'xcodeproj'

ROOT = File.expand_path(__dir__)
APP_NAME = 'LazyButNot'
APP_DIR = File.join(ROOT, APP_NAME)
PROJECT_PATH = File.join(APP_DIR, "#{APP_NAME}.xcodeproj")
BUNDLE_ID = 'com.kl.LazyButNot'
IOS_DEPLOYMENT_TARGET = '17.0'

FileUtils.mkdir_p(APP_DIR)
FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes['LastUpgradeCheck'] = '2610'
project.root_object.attributes['ORGANIZATIONNAME'] = 'kl'

app_group = project.main_group.new_group(APP_NAME)
products_group = project.products_group

target = project.new_target(:application, APP_NAME, :ios, IOS_DEPLOYMENT_TARGET, products_group, :swift)
target.product_reference.name = "#{APP_NAME}.app"
target.product_reference.path = "#{APP_NAME}.app"

[
  'App',
  'Models',
  'Stores',
  'Services',
  'ViewModels',
  'Views',
  'Views/Components',
  'Preview Content',
].each do |relative_path|
  segments = relative_path.split('/')
  current_group = app_group
  current_path = APP_NAME
  segments.each do |segment|
    current_path = File.join(current_path, segment)
    existing = current_group.children.find do |child|
      child.isa == 'PBXGroup' && child.display_name == segment
    end
    current_group = existing || current_group.new_group(segment, segment)
  end
end

def ensure_group(root_group, relative_path)
  relative_path.split('/').reduce(root_group) do |current_group, segment|
    existing = current_group.children.find do |child|
      child.isa == 'PBXGroup' && child.display_name == segment
    end
    existing || current_group.new_group(segment, segment)
  end
end

def add_file_reference(root_group, relative_path)
  directory = File.dirname(relative_path)
  filename = File.basename(relative_path)
  parent_group = directory == '.' ? root_group : ensure_group(root_group, directory)

  existing = parent_group.children.find do |child|
    child.isa != 'PBXGroup' && child.respond_to?(:path) && child.path == filename
  end

  existing || parent_group.new_file(filename)
end

source_paths = [
  'LazyButNotApp.swift',
  'App/AppRouter.swift',
  'App/RootTabView.swift',
  'Models/Enums.swift',
  'Models/Goal.swift',
  'Models/CheckInRecord.swift',
  'Stores/GoalStore.swift',
  'Services/NotificationManager.swift',
  'ViewModels/GoalFormViewModel.swift',
  'Views/HomeDashboardView.swift',
  'Views/GoalsListView.swift',
  'Views/GoalDetailView.swift',
  'Views/GoalFormView.swift',
  'Views/StatsView.swift',
  'Views/SettingsView.swift',
  'Views/Components/EmptyStateView.swift',
  'Views/Components/ProgressRingView.swift',
  'Views/Components/GoalCardView.swift',
]

source_refs = source_paths.map { |path| add_file_reference(app_group, path) }

target.add_file_references(source_refs)
target.add_system_framework('UserNotifications')

project.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
  config.build_settings['MARKETING_VERSION'] = '1.0'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  config.build_settings['DEVELOPMENT_TEAM'] = ''
end

target.build_configurations.each do |config|
  settings = config.build_settings
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['CURRENT_PROJECT_VERSION'] = '1'
  settings['DEVELOPMENT_TEAM'] = ''
  settings['ENABLE_PREVIEWS'] = 'YES'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['INFOPLIST_KEY_CFBundleDisplayName'] = '懒人不懒'
  settings['INFOPLIST_KEY_LSApplicationCategoryType'] = 'public.app-category.productivity'
  settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
  settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  settings['INFOPLIST_KEY_UNUserNotificationAlertStyle'] = 'alert'
  settings['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  settings['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
  settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks']
  settings['MARKETING_VERSION'] = '1.0'
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE_ID
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
  settings['SUPPORTS_MACCATALYST'] = 'NO'
  settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
end

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(target, nil, launch_target: true)
scheme.save_as(PROJECT_PATH, APP_NAME, true)

project.save
