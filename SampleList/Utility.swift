import Foundation
import Kingfisher
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

    func mapToOptional() -> Observable<Element?> {
        return map({ $0 })
    }
}

extension SharedSequence where SharingStrategy == DriverSharingStrategy {
    func mapToVoid() -> Driver<Void> {
        return map({ _ in }).asDriver(onErrorJustReturn: ())
    }
}

extension Reactive where Base: UIViewController {
    var isViewAppear: Driver<Bool> {
        let source = methodInvoked(#selector(Base.viewWillAppear(_:))).map({ _ in true })
        let source2 = methodInvoked(#selector(Base.viewWillDisappear(_:))).map({ _ in false })
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

extension UIImageView {
    func downLaodImageWith(url: String) {
        kf.setImage(with: URL(string: url))
    }

    func cancelDownloadImage() {
        kf.cancelDownloadTask()
    }
}

extension UIView {
    var showErrorToast: Binder<ErrorDisplay?> {
        return .init(self, binding: { _weakView, errorInfo in
            guard let errorInfo else { return }
            let toastLabel = UILabel(frame: .zero)
            _weakView.addSubview(toastLabel)
            toastLabel.layer.cornerRadius = 10
            toastLabel.layer.masksToBounds = true
            toastLabel.backgroundColor = .lightGray.withAlphaComponent(0.6)
            toastLabel.textAlignment = .center
            toastLabel.snp.makeConstraints({
                $0.center.equalToSuperview()
                $0.width.equalTo(200)
                $0.height.equalTo(50)
            })

            toastLabel.text = errorInfo.tile
            toastLabel.alpha = 0

            UIView.animate(withDuration: 0.3, animations: {
                toastLabel.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 1, animations: {
                    toastLabel.alpha = 0
                }, completion: { _ in
                    toastLabel.removeFromSuperview()
                })
            })
        })
    }
}

enum UIFactory {
    static func createIndicatorView() -> UIActivityIndicatorView {
        let _indicator = UIActivityIndicatorView(style: .large)
        _indicator.color = .lightGray
        _indicator.hidesWhenStopped = true
        return _indicator
    }

    static func createFavoriteBtn() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        btn.setImage(UIImage(systemName: "star.fill"), for: .selected)
        return btn
    }
}
