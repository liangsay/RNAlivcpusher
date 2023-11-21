require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'


#use_frameworks!
platform :ios, '12.4'
install! 'cocoapods', :deterministic_uuids => false

LIVE_SDK ='AliVCSDK_PremiumLive'
QUEEN_SPEC=LIVE_SDK

def aliyun_video_sdk
    # 根据自己的业务场景，集成合适的音视频终端SDK
    # 如果你的APP中还需要频短视频编辑功能，可以使用音视频终端全功能SDK（AliVCSDK_Premium），可以把本文件中的所有AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AliVCSDK_PremiumLive', '~> 6.4.0'
end

def aliyun_aui_interaction_live
    # 基础UI组件
    pod 'AUIFoundation/All', :path => "./AUIBaseKits/AUIFoundation/"

    # 美颜UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AUIBeauty/AliVCSDK_PremiumLive', :path => "./AUIBaseKits/AUIBeauty/"

    # 互动消息组件
    pod 'AUIMessage/Alivc', :path => "./AUIBaseKits/AUIMessage/"

    # 互动直播UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'RNAlivcpusher/AliVCSDK_PremiumLive',  :path => "./"
end


def aliyun_aui_enterprise_live
    # 基础UI组件
    pod 'AUIFoundation/All', :path => "./AUIBaseKits/AUIFoundation/"

    # 互动消息组件
    pod 'AUIMessage/Alivc', :path => "./AUIBaseKits/AUIMessage/"

    # 企业直播UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AUIEnterpriseLive/AliVCSDK_PremiumLive',  :path => "./"
end

def common_demo_pods
    pod 'Masonry'
    pod 'MJRefresh'
    pod 'SDWebImage'
    pod 'MJExtension'
    #pod 'Queen', :path => "./"
end


target 'RNAlivcpusher' do
  config = use_native_modules!

  # Flags change depending on the env values.
  flags = get_default_flags()

  use_react_native!(
    :path => config[:reactNativePath],
    # to enable hermes on iOS, change `false` to `true` and then install pods
    :hermes_enabled => true,##flags[:hermes_enabled],
    :fabric_enabled => flags[:fabric_enabled],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )

    common_demo_pods
    aliyun_aui_interaction_live
    aliyun_video_sdk

use_flipper!()

  post_install do |installer|
    react_native_post_install(installer)
    __apply_Xcode_12_5_M1_post_install_workaround(installer)
    installer.pods_project.targets.each do |target|
               target.build_configurations.each do |config|
    #               config.build_settings['OTHER_CPLUSPLUSFLAGS'] = ''
                   config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = "arm64"
                   config.build_settings["DEVELOPMENT_TEAM"] = "EZLGLB84UG"
                   config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
                   config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'NO'
                   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
               end
           end
        installer.pods_project.build_configurations.each do |config|
                config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
              end
  end
end

