# IMAccountKit 使用指南

通过 CocoaPods 引入（`import IMAccountKit`，通知和本地化需要 `import IMBaseKit`，导航和 Toast 需要 `import IMUIKit`）。安装见仓库根目录 [README.md](../README.md)，隐私清单见 [PRIVACY.md](PRIVACY.md)。可运行示例在 `Example/`。

二进制是 **static XCFramework**。IMBaseKit、IMUIKit、ActiveLabel、Kingfisher、RxSwift、SnapKit、Then 不打进包，由宿主链接同一份。

勾选图标在名为 **IMAccountKit** 的 bundle 里：`Agree`、`Disagree`。静态链接时这个 bundle 在主 App 里。库会先查类所在 bundle，再查主 bundle。不要重命名。登录文案在 IMBaseKit 的语言包里，不在本 bundle。

默认这份二进制是国内版：手机号 + 短信验证码。`#if INMOX_GLOBAL` 在打包时已经裁成国内分支，宿主的编译条件改不了登录方式。

---

## 启动

```swift
import IMAccountKit
import IMBaseKit

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    IMLaunchManager.shared.launch(forKey: IMLaunchKey.sdk)
    IMUtils.set(uid: IMAccountManager.shared.accountInfo?.userId,
                token: IMAccountManager.shared.accountInfo?.accessToken)
    return true
}
```

`launch` 会注册 IMUIKit 的网页路由和本库的 `IMAccountKitRouterService`。登录页上的协议链接、`openRouter` 打开地区选择或注销页，都依赖这一步。冷启动恢复本地账户时不会自己调用 `IMUtils.set`，启动期要补一次。

## 登录页

`IMLoginViewController` 会 push 验证码页，必须放在导航控制器里。登录成功后页面不自动关闭，只发通知。

```swift
import IMUIKit
import IMAccountKit

window.rootViewController = IMBaseNavigationController(rootViewController: IMLoginViewController())
```

国内版显示 `+86`、数字键盘，校验 11 位数字，接口 `type` 为 `PHONE`。

## 状态

```swift
let manager = IMAccountManager.shared
if manager.isLoggedIn, let info = manager.accountInfo {
    info.userId
    info.accessToken
    info.displayName   // nickname ?? account
}
```

`accountInfo` 在第一次访问 `shared` 时从 MMKV 同步恢复。`refreshToken` 不对外暴露。

| 通知 | 时机 | `object` |
|------|------|----------|
| `.im.accountDidLogin` | 验证码登录成功 | nil |
| `.im.accountDidLogout` | `logOut` 成功，或令牌失效被动登出 | nil |
| `.im.accountDidUnregister` | `unregister` 成功 | 被注销的 `userId: String` |
| `.im.accountInfoDidUpdate` | 登录、静默刷新、拉资料、改资料、传头像成功 | nil |

通知在网络回调线程发出。监听时用 `queue: .main`。登出和注销成功后要自己把 `IMUtils.set(uid:token:)` 清掉，SDK 不会替宿主清请求头。

## 登出、注销、资料

```swift
IMAccountManager.shared.logOut { isSuccess, errorMsg in }
IMAccountManager.shared.unregister { isSuccess, errorMsg in }
IMAccountManager.shared.undoUnregister { isSuccess, errorMsg in }

IMAccountManager.shared.queryAccountInfo { isSuccess, errorMsg in }
IMAccountManager.shared.updateUserInfo("新昵称", timezone: nil) { isSuccess, errorMsg in }
IMAccountManager.shared.uploadAvatar(jpegData, fileName: nil) { isSuccess, errorMsg in }
```

`logOut` 要等接口成功才清本地。无网时仍是登录态。`fileName` 为 nil 时用 `<userId>_<yyyyMMdd>.jpg`，按 `image/jpeg` 上传。本库不打开相册，图片 `Data` 由宿主传入。

协议：

```swift
IMAccountManager.shared.queryTerms { terms in
    // 每项含 id / type / contentUrl
    // type：IMAccountManager.TermsType.agreement = USER_AGREEMENT
    //       IMAccountManager.TermsType.privacy = PRIVACY_POLICY
}
IMAccountManager.shared.acceptTerms(ids) { isSuccess, errorMsg in }
```

`queryTerms(false)` 不显示加载 Toast。结果缓存在内存，收到内存警告才清空。协议弹层兜底文案的第一个参数是 `Bundle.im.appName`，不再写死应用名。`IMBuildRegion.isINMOMoment` 为 true 时，查询会带 `productCode=INMO_MOMENT_APP`。

设备：

```swift
IMAccountManager.shared.bindDevice(sn) { isSuccess, errorMsg in }
IMAccountManager.shared.unbindDevice(sn) { isSuccess, errorMsg in }
IMAccountManager.shared.bindedDevices { isSuccess, errorMsg in }
```

`bindedDevices` 只回调成功与否，不返回列表。

## 路由

`openRouter` 会把 `accountKit` 分到本库注册的服务：

| URL | 页面 |
|-----|------|
| `inmox://accountKit/regionSelect` | 国家与地区。`params["region"]` 为 `RegionOption`，可选 `params["onSelect"]` |
| `inmox://accountKit/unregisterAccount` | 注销账号 |

账号与安全仍是 `inmox://hostApp/accountSecurity`，由宿主实现。

## 凭证

| 数据 | 位置 | Key |
|------|------|-----|
| 上次登录的手机号或邮箱 | 钥匙串，`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` | `im_account_user_account` |
| 账户 JSON，含 accessToken、refreshToken、过期时间 | MMKV，`Documents/` | `accountInfo.user` |

登出不删钥匙串里的上次账号，登录页用来预填。`clearAllCache` 会清掉 MMKV 里的账户，但不发登出通知。

accessToken 距过期不足 5 分钟时，冷启动会静默刷新。走 IMBaseKit 网络层时，业务码 `40102` 会刷新并最多重试 2 次；`40100` / `40101` / `40103` / `10103` 直接清本地并发 `accountDidLogout`。自建网络层要自己带 `Authorization`，并在 `40102` 时调一次 SDK 接口触发刷新。

账号接口域名来自 `IMEnvironmentManager.shared.environmentModels["account"]?.baseUrl`，为空时用 IMBaseKit 的 `Environment.baseUrlString`。这份静态库按 Release 打包，库内没有 DEBUG / ADHOC 分支。要切测试环境，宿主把 `allowsEnvironmentSwitch` 设为 true。

## 地区勾选图标

选中国家时，行尾图标用 `UIImage(named: "Check")`，查的是主 bundle，不是 `IMAccountKit.bundle`。宿主若需要这个勾，在自己的 Asset Catalog 里放名为 `Check` 的图。协议勾选框的 `Agree` / `Disagree` 在本库 bundle 里。

## 常见问题

**启动该进主页还是登录页？**  
读 `IMAccountManager.shared.isLoggedIn`。它同步恢复本地状态。

**协议链接没反应？**  
先执行 `IMLaunchManager.shared.launch(forKey: IMLaunchKey.sdk)`，让 IMUIKit 注册内置网页路由。

**一直停在登录态？**  
启动期要 `IMUtils.set(uid:token:)`。请求须走 IMBaseKit 网络层。

**`errorMsg`？**  
已按当前语言映射成可展示文案。

**能不引 IMUIKit 吗？**  
不能。登录页基类、导航、Toast、弹层都在 IMUIKit。
