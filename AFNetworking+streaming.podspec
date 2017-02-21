#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "AFNetworking+streaming"
  s.version          = '0.6.3'
  s.summary          = "A very quick extension to AFNetworking that adds stream based parsing"
  s.description      = <<-DESC
			A very quick extension to AFNetworking that adds stream based parsing.
			
			Checkout the project in the Example folder for an example of parsing a json file as it arrives, not when it's all downloaded.
			DESC
  s.homepage         = "https://github.com/deanWombourne/AFNetworking-streaming"
  s.license          = 'MIT'
  s.author           = { "Sam Dean" => "deanWombourne@gmail.com" }
  s.source           = { :git => "https://github.com/deanWombourne/AFNetworking-streaming.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.subspec 'Core' do |ss|
    ss.source_files = 'Classes/Core'
  end

  s.subspec 'Json' do |ss|
    ss.source_files = 'Classes/Json'
    ss.dependency 'SBJson4', '~> 4'
    ss.dependency 'AFNetworking+streaming/Core', s.version.to_s
  end

  s.dependency 'AFNetworking', '~> 2.3'
end
