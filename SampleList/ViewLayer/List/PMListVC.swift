
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class PMListVC: UIViewController {
    private let viewModel: PMListViewModel
    private let bag: DisposeBag = .init()
    private let didScroll: PublishRelay<PMListViewModel.ScrollInfo> = .init()
    private var dataDisplay: [PMCellDisplayable] = .init()
    private let refreshControl: UIRefreshControl = .init()
    private let indicatorView: UIActivityIndicatorView = {
        let _indicator = UIActivityIndicatorView.init(style: .large)
        _indicator.color = .lightGray
        _indicator.hidesWhenStopped = true
        return _indicator
    }()
    private let collectionview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: 400, height: 80)
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(PMListCell.self, forCellWithReuseIdentifier: PMListCell.cellID)
        collection.alwaysBounceVertical = true
        return collection
    }()

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
        defer {
            collectionview.delegate = self
            collectionview.dataSource = self
        }
        setupUI()
        bindViewModel()
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
                favriateClick: .empty())
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
    }

    private var dataChangeDisplay: Binder<[PMCellDisplayable]> {
        return .init(self, binding: { _self, datas in
            _self.dataDisplay = datas
            _self.view.layoutIfNeeded()
            _self.collectionview.reloadData()
        })
    }

    private  var indicatroDisplay: Binder<Bool> {
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
}

// MARK: UICollectionViewDataSource
extension PMListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataDisplay.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PMListCell.cellID, for: indexPath)
        (cell as? PMListCell)?.config(with: dataDisplay[indexPath.row])
        return cell
    }
}
