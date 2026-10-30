# Privacy（IMAccountKit）

## 隐私清单

`IMAccountKit/Resources/PrivacyInfo.xcprivacy`：

| Key | 取值 |
|-----|------|
| `NSPrivacyTracking` | `false`。不做跨 App / 网站追踪。 |
| `NSPrivacyTrackingDomains` | 空 |
| `NSPrivacyCollectedDataTypes` | 见下表。都与用户关联，不用于追踪，目的是 App 功能 |
| `NSPrivacyAccessedAPITypes` | 空。本库不调用 UserDefaults、文件时间戳、开机时间、磁盘空间、键盘等需声明原因的 API |

| 收集类型 | 何时发生 |
|----------|----------|
| 电话号码 | 国内版登录页把手机号交给账号接口换验证码、登录 |
| 电子邮箱 | 宿主为海外包（`IMBuildRegion.isGlobal`，当前是 `com.inmox.next.global`）时，登录页把邮箱交给账号接口。国内包走手机号，不收集邮箱。同一份二进制包含两条路径 |
| 用户 ID | 登录成功后写入本地账户模型，并随资料、设备绑定等请求带上 |
| 姓名 | `updateUserInfo` 把昵称发给账号接口。清单用 `NSPrivacyCollectedDataTypeName` |
| 照片或视频 | `uploadAvatar` 把宿主传入的图片 `Data` 上传。本库不打开相册、不申请照片权限 |

二进制有两份同一清单：

1. 每个 XCFramework 切片里的 `IMAccountKit.framework/PrivacyInfo.xcprivacy`
2. CocoaPods 资源包 `IMAccountKit.bundle`。静态库不会被嵌入 App，只放在 framework 里时系统带不走这份清单

钥匙串和 MMKV 由 IMBaseKit 访问，原因码在 IMBaseKit 自己的清单里。Kingfisher、Alamofire 等依赖各自带清单，不合并进本库。

## 宿主 Info.plist

本库不直接申请相机、相册、定位、蓝牙。头像若由宿主自己选图再交给 `uploadAvatar`，照片权限文案写在宿主的选图流程上。

## 其它

- 不采集 IDFA，不追踪。
- 登录、资料、头像、设备绑定都会把上述数据发到账号服务。宿主的 App 隐私营养标签按实际上传内容填写。
- 上次登录的手机号或邮箱存在钥匙串（`im_account_user_account`），账户 JSON（含 token）存在 MMKV。登出不删钥匙串里的上次账号。
- 导出合规（传输使用的系统加密）由宿主问卷填写。产物未签名，不含 bitcode，不含 dSYM。
