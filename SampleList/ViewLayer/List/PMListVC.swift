import RxCocoa
import RxSwift
import SnapKit
import UIKit

class PMListVC: UIViewController {
    private let viewModel: PMListVM
    private let bag: DisposeBag = .init()
    private let didScroll: PublishRelay<PMListVM.ScrollInfo> = .init()
    private let barItemClick: PublishRelay<Void> = .init()
    private let itemSelected: PublishRelay<IndexPath> = .init()

    private var dataDisplay: [PMCellDisplayable] = .init()
    private let refreshControl: UIRefreshControl = .init()

    private let indicatorView: UIActivityIndicatorView = UIFactory.createIndicatorView()

    private let collectionview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: 400, height: 80)
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(PMListCell.self, forCellWithReuseIdentifier: PMListCell.cellID)
        collection.alwaysBounceVertical = true
        return collection
    }()

    init(viewModel: PMListVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = PMListVM(coordinator: .init(nav: nil))
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        defer {
            collectionview.delegate = self
            collectionview.dataSource = self
        }
        setupUI()
        bindViewModel()
        let barItem: UIBarButtonItem = .init(systemItem: .compose,
                                             primaryAction: .init(handler: { [weak barItemClick] _ in
                                                 barItemClick?.accept(())
                                             }))

        navigationItem.setRightBarButtonItems([barItem], animated: false)
    }

    private func setupUI() {
        view.addSubview(collectionview)
        view.addSubview(indicatorView)
        collectionview.addSubview(refreshControl)
        collectionview.snp.makeConstraints({
            $0.top.bottom.leading.trailing.equalToSuperview()
        })
        indicatorView.snp.makeConstraints({
            $0.center.equalToSuperview()
        })
    }

    private func bindViewModel() {
        let output = viewModel.transfrom(input:
            .init(
                isViewAppear: rx.isViewAppear,
                scrollInfo: didScroll.asDriver(onErrorJustReturn: .zero()),
                refresh: refreshControl.rx.controlEvent(.valueChanged).asDriver(),
                switchClick: .empty(),
                favriateSwitch: barItemClick.asDriver(onErrorDriveWith: .empty()),
                itemSelected: itemSelected.asDriver(onErrorDriveWith: .empty()))
        )

        output.dataChanged
            .drive(dataChangeDisplay)
            .disposed(by: bag)

        output.indicator
            .drive(indicatroDisplay)
            .disposed(by: bag)

        output.errorDisplay
            .drive(view.showErrorToast)
            .disposed(by: bag)

        output.config
            .drive()
            .disposed(by: bag)
    }

    private var dataChangeDisplay: Binder<[PMCellDisplayable]> {
        return .init(self, binding: { _self, datas in
            _self.dataDisplay = datas
            _self.view.layoutIfNeeded()
            _self.collectionview.reloadData()
        })
    }

    private var indicatroDisplay: Binder<Bool> {
        return .init(self, binding: { _weakSelf, show in
            if show {
                _weakSelf.indicatorView.startAnimating()
            } else {
                _weakSelf.indicatorView.stopAnimating()
                _weakSelf.refreshControl.endRefreshing()
            }
        })
    }
}

// MARK: UICollectionViewDelegate
extension PMListVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll.accept(.init(offst: scrollView.contentOffset,
                               contentSize: scrollView.contentSize,
                               boundSize: scrollView.bounds.size))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemSelected.accept(indexPath)
    }
}

// MARK: UICollectionViewDataSource
extension PMListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataDisplay.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PMListCell.cellID, for: indexPath)
        (cell as? PMListCell)?.config(with: dataDisplay[indexPath.row])
        return cell
    }
}
