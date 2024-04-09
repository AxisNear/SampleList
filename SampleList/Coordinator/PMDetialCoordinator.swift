//
//  PMDetialCoordinator.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/9.
//

import Foundation
import UIKit

class PMDetialCoordinator: CoordinatorProtocol {
    private weak var nav: UINavigationController?
    private let pokemonName: String
    
    init(nav: UINavigationController?, name: String) {
        self.nav = nav
        self.pokemonName = name
    }
    
    func start(animate: Bool) {
        let vm = PMDetailVM(name: pokemonName)
        let detilVC = PMDetialVC(vm: vm)
        nav?.pushViewController(detilVC, animated: animate)
    }

    deinit {
        print("PMDetialCoordinator deinit")
    }

}
