# IMAccountKit

INMO 私有账户库的 **静态 XCFramework**。提供登录状态、验证码登录页、令牌续期、资料与设备绑定。

IMBaseKit、IMUIKit、ActiveLabel、Kingfisher、RxSwift、SnapKit、Then **不打进包**，由宿主链接同一份。

---

## 环境要求

- iOS 15.0+
- Swift 5
- Xcode 15+
- CocoaPods，并开启 `use_frameworks!`

## 安装

```ruby
platform :ios, '15.0'
use_frameworks! :linkage => :static

target 'YourApp' do
  pod 'IMBaseKit',    :git => 'https://github.com/INMO-X/IMBaseKit.git', :tag => '0.1.0'
  pod 'IMUIKit',      :git => 'https://github.com/INMO-X/IMUIKit.git', :tag => '0.1.0'
  pod 'IMAccountKit', :git => 'https://github.com/INMO-X/IMAccountKit.git', :tag => '0.1.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
```

`pod install` 后勾选图标在 **`IMAccountKit.bundle`**（`Agree`、`Disagree`）。不要重命名。静态链接时库会先查类所在 bundle，再查主 bundle。

这份 0.1.0 是国内版：手机号 + 短信验证码。库内 `#if INMOX_GLOBAL` 已在打包时确定，宿主编译条件改不了。

依赖版本与打这个包时一致：IMBaseKit 0.1.0、IMUIKit 0.1.0、ActiveLabel 1.1.0、Kingfisher 8.12.0、RxSwift / RxCocoa 6.9.0、SnapKit 5.7.1、Then 3.0.0。

## 示例

[Example/](Example/) 用 tag `0.1.0` 检查 bundle 图片，并打开登录页。

```bash
cd Example
pod install
open IMAccountKit.xcworkspace
```

## 文档

| 文档 | 说明 |
|------|------|
| [docs/USAGE.md](docs/USAGE.md) | 场景用法 |
| [docs/PRIVACY.md](docs/PRIVACY.md) | 隐私清单与宿主配置 |
