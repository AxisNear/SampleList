//
//  PMDetialVC.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/9.
//

import UIKit

class PMDetialVC: UIViewController {
    private let vm: PMDetailVM

    init(vm: PMDetailVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.vm = PMDetailVM(name: "")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
