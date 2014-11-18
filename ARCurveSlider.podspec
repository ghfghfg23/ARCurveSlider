#
# Be sure to run `pod lib lint ARCurveSlider.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ARCurveSlider"
  s.version          = "0.2.0"
  s.summary          = "Curve slider control for iOS"
  s.description      = <<-DESC
UISlider with circle form for iOS. Handle UIControlEventValueChanged event and take value from "value" property.

                    DESC
  s.homepage         = "https://github.com/ghfghfg23/ARCurveSlider"
  s.license          = 'MIT'
  s.author           = { "Andrey Ryabov" => "ghfghfg23@gmail.com" }
  s.source           = { :git => "https://github.com/ghfghfg23/ARCurveSlider.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

s.source_files = 'Pod/Classes/ARCurveSlider.{h,m}'
  s.resource_bundles = {
    'ARCurveSlider' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
