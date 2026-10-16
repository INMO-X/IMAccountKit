import IMAccountKit
import IMUIKit
import UIKit

/// 检查 IMAccountKit.bundle 里的勾选图标，并打开登录页。
final class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let resourceNames = ["Agree", "Disagree"]
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IMAccountKit"
        view.backgroundColor = .systemBackground
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? resourceNames.count : 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "IMAccountKit.bundle 图片" : "登录"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .none
        cell.imageView?.image = nil
        cell.detailTextLabel?.text = nil
        if indexPath.section == 0 {
            let name = resourceNames[indexPath.row]
            let image = Self.sdkImage(named: name)
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = image == nil ? "未找到" : "已找到"
            cell.imageView?.image = image
        } else {
            cell.textLabel?.text = "打开登录页"
            cell.detailTextLabel?.text = IMAccountManager.shared.isLoggedIn ? "本地已登录" : "本地未登录"
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section == 1 else { return }
        navigationController?.pushViewController(IMLoginViewController(), animated: true)
    }

    /// 与库内查找顺序一致：类所在 bundle，再主 bundle，资源名必须是 IMAccountKit。
    private static func sdkImage(named name: String) -> UIImage? {
        var containers: [Bundle] = [Bundle(for: IMAccountManager.self)]
        if Bundle.main !== containers.last {
            containers.append(Bundle.main)
        }
        for container in containers {
            if let url = container.url(forResource: "IMAccountKit", withExtension: "bundle"),
               let bundle = Bundle(url: url),
               let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
                return image
            }
        }
        return nil
    }
}
