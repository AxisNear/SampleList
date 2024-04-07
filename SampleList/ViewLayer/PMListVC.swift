
import UIKit

class PMListVC: UIViewController {
    let viewModel: PMListViewModel

    init(viewModel: PMListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = PMListViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bindViewModel() {
        let output = viewModel.transfrom(input:
            .init(
                isViewAppear: rx.isViewAppear,
                scrollInfo: .empty(),
                refresh: .empty(),
                switchClick: .empty(),
                favriateClick: .empty())
        )
    }
}
