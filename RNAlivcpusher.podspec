#
# Be sure to run `pod lib lint RNAlivcpusher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RNAlivcpusher'
  s.version          = '2.2.0'
  s.summary          = 'A short description of RNAlivcpusher.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/aliyunvideo/RNAlivcpusher_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :text => 'LICENSE' }
  s.author           = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.source           = { :git => 'https://github.com/aliyunvideo/RNAlivcpusher_iOS', :tag =>"v#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.default_subspecs='AliVCSDK_PremiumLive'
  s.pod_target_xcconfig = {'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) COCOAPODS=1 DISABLE_QUEEN'}


    s.subspec 'RNView' do |ss|
        ss.source_files = "RNAlivcpusher/RNView/*.{h,m}"
    end
    s.subspec 'RNModule' do |ss|
        ss.source_files = "RNAlivcpusher/RNModule/*.{h,m}"
    end
    s.subspec 'Extension' do |ss|
        ss.source_files = "Extension/*.{h,m}"
    end
  s.subspec 'RNAliplayer' do |ss|
    #ss.dependency "AliPlayerSDK_iOS","6.7.0-33219355"
    ss.source_files  = "RNAliplayer/**/*.{h,m}"
  end

  s.subspec 'Live' do |ss|
    ss.resource = 'Resources/*.bundle'
    ss.source_files = 'Source/**/*.{h,m,mm}'
    ss.dependency 'AUIFoundation/All'
    ss.dependency 'AUIMessage'
    ss.dependency 'RNAlivcpusher/RNView'
    ss.dependency 'RNAlivcpusher/RNModule'
    ss.dependency 'RNAlivcpusher/RNAliplayer'
    ss.dependency 'RNAlivcpusher/Extension'
    ss.dependency 'Masonry'
    ss.dependency 'MJRefresh'
    ss.dependency 'SDWebImage'
  end

  s.subspec 'AliVCSDK_Premium' do |ss|
    ss.dependency 'RNAlivcpusher/Live'
    ss.dependency 'AliVCSDK_Premium'
    ss.dependency 'AUIBeauty/AliVCSDK_Premium'
  end

  s.subspec 'AliVCSDK_InteractiveLive' do |ss|
    ss.dependency 'RNAlivcpusher/Live'
    ss.dependency 'AliVCSDK_InteractiveLive'
    ss.dependency 'AUIBeauty/Queen'
  end

  s.subspec 'AliVCSDK_PremiumLive' do |ss|
    ss.dependency 'RNAlivcpusher/Live'
    ss.dependency 'AliVCSDK_PremiumLive'
    ss.dependency 'AUIBeauty/AliVCSDK_PremiumLive'
  end

  s.subspec 'AliVCSDK_Standard' do |ss|
    ss.dependency 'RNAlivcpusher/Live'
    ss.dependency 'AliVCSDK_Standard'
  end
    s.dependency 'React'
end
