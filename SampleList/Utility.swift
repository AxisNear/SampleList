//
//  Utility.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/6.
//

import Foundation
import RxCocoa
import RxSwift

extension ObservableType {
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }

    func trackError(errorRelay: PublishRelay<Error?>) -> Observable<Element> {
        return self.do(onError: { [weak errorRelay] error in
            errorRelay?.accept(error)
        }, onCompleted: { [weak errorRelay] in
            errorRelay?.accept(nil)
        })
    }

    func trackIndicator(indicator: PublishRelay<Bool>) -> Observable<Element> {
        return self.do(onSubscribed: { [weak indicator] in
            indicator?.accept(true)
        }, onDispose: { [weak indicator] in
            indicator?.accept(false)
        })
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


struct ErrorDisplay: Equatable {
    let tile: String = "網路錯誤嘍"
}

extension Error {
    func covertToDisplayError() -> ErrorDisplay {
        return ErrorDisplay()
    }
}
