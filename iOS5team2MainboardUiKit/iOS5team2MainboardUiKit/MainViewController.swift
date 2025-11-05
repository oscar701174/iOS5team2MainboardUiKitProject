import UIKit

class MainViewController: UIViewController {
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabel()
    }
    
    func setLabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        label.text = "Hello,Team Mainboard!"
        label.textAlignment = .center
        label.textColor = .yellow
        
    }
}
