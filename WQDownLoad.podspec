#
# Be sure to run `pod lib lint WQDownLoad.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WQDownLoad'
  s.version          = '0.2.0'
  s.summary          = 'iOS 下载框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
iOS 下载框架,视频配套信息存储基于FMDB, 下载实现基于NSURLSessionDataTask + audio airplay and picture 后台播放无声音频 (NSURLSessionDownloadTask功能未完善,后台下载数据库操作,resumeData问题)
                       DESC

  s.homepage         = 'https://github.com/hapiii/WQDownLoad'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hapiii' => '869932084@qq.com' }
  s.source           = { :git => 'https://github.com/hapiii/WQDownLoad.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WQDownLoad/Classes/**/*'
  
   s.resource_bundles = {
     'WQDownLoad' => ['WQDownLoad/Assets/*']
   }
{"name"=>["hapii"], "email"=>["869932084@qq.com"]}
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'YYKit'
    s.dependency 'AFNetworking'
    s.dependency 'FMDB'
    s.dependency 'SDWebImage'
    
end
