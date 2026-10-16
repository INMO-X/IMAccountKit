#
# Binary pod for the static XCFramework produced by Scripts/build_xcframeworks.sh.
# IMBaseKit, IMUIKit and third-party pods stay dependencies of the host. They are not vendored.
#
Pod::Spec.new do |s|
  s.name             = 'IMAccountKit'
  s.version          = '0.1.0'
  s.summary          = 'INMO X Project Account Kit (static XCFramework)'
  s.description      = <<-DESC
  INMO X 项目私有账户库的静态二进制。
  IMBaseKit / IMUIKit / ActiveLabel / Kingfisher / RxSwift / RxCocoa / SnapKit / Then
  由宿主工程链接同一份，不打进本 XCFramework。
                       DESC

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jiangqi' => 'jiangqi@inmolens.com' }
  s.homepage         = 'https://github.com/INMO-X/IMAccountKit'
  s.source           = { :git => 'https://github.com/INMO-X/IMAccountKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version    = '5.0'
  s.static_framework = true

  s.vendored_frameworks = 'XCFrameworks/IMAccountKit.xcframework'

  s.frameworks = [
    'UIKit',
    'Foundation',
    'Security'
  ]

  # 勾选图标与隐私清单。运行时只在名为 IMAccountKit 的 bundle 里查图。
  s.resource_bundles = {
    'IMAccountKit' => [
      'IMAccountKit/Resources/**/*.{xcassets,lproj}',
      'IMAccountKit/Resources/PrivacyInfo.xcprivacy'
    ]
  }

  s.dependency 'IMBaseKit', '0.1.0'
  s.dependency 'IMUIKit', '0.1.0'
  s.dependency 'ActiveLabel', '1.1.0'
  s.dependency 'Kingfisher', '8.12.0'
  s.dependency 'RxCocoa', '6.9.0'
  s.dependency 'RxSwift', '6.9.0'
  s.dependency 'SnapKit', '5.7.1'
  s.dependency 'Then', '3.0.0'
end
