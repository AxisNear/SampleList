//
//  PMListCoordinator.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/9.
//

import Foundation
import UIKit

class PMListCoordinator: CoordinatorProtocol {
    private weak var nav: UINavigationController?

    init(nav: UINavigationController?) {
        self.nav = nav
    }

    func start(animate: Bool = false) {
        let vc = PMListVC(viewModel: PMListVM(coordinator: self))
        nav?.pushViewController(vc, animated: animate)
    }

    func showDetial(name: String) {
        let deial = PMDetialCoordinator(nav: nav, name: name)
        deial.start(animate: true)
    }

    deinit {
        print("PMListCoordinator deinit")
    }
}
