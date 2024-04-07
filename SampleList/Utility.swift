//
//  Utility.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/6.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

extension SharedSequence where SharingStrategy == DriverSharingStrategy {
    func mapToVoid() -> Driver<Void> {
        return map({ _ in }).asDriver(onErrorJustReturn: ())
    }
}

extension Reactive where Base: UIViewController {
    var isViewAppear: Driver<Bool> {
        let source = methodInvoked(#selector(Base.viewDidAppear(_:))).map({ _ in true })
        let source2 = methodInvoked(#selector(Base.viewDidDisappear(_:))).map({ _ in false })
        return Observable<Bool>.merge(source, source2).asDriver(onErrorJustReturn: false)
    }
}
