//
//  PMDetialVC.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/9.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class PMDetialVC: UIViewController {
    private let vm: PMDetailVM
    private let bag: DisposeBag = .init()

    private let indicatorView: UIActivityIndicatorView = UIFactory.createIndicatorView()
    private let nameLabel = UILabel()
    private let imageView = UIImageView()
    private let idLabel = UILabel()
    private let typeslabel = UILabel()
    private let favorteBtn: UIButton = UIFactory.createFavoriteBtn()
    private let itemSelected: PublishRelay<IndexPath> = .init()
    private let descriptionlabel = UILabel()
    private let collectionview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: 400, height: 80)
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(PMListCell.self, forCellWithReuseIdentifier: PMListCell.cellID)
        collection.alwaysBounceVertical = true
        return collection
    }()

    private var dataDisplay: [PMCellDisplayable] = .init()

    init(vm: PMDetailVM) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.vm = PMDetailVM(name: "", coordinator: .init(nav: nil, name: ""))
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindEvnet()
        let barItem: UIBarButtonItem = .init(customView: favorteBtn)
        navigationItem.setRightBarButtonItems([barItem], animated: false)
        collectionview.delegate = self
        collectionview.dataSource = self
    }

    private func bindEvnet() {
        let output = vm.trasfrom(input: .init(
            viewAppear: rx.isViewAppear,
            favoriteClick: favorteBtn.rx.controlEvent(.touchUpInside).asDriver(),
            showPokemon: itemSelected.asDriver(onErrorDriveWith: .empty())
        ))
        output.description
            .drive(desDisplay)
            .disposed(by: bag)

        output.chain
            .drive(chainDisplay)
            .disposed(by: bag)

        output.pokemonInfo
            .drive(infoDisplay)
            .disposed(by: bag)

        output.errorDisplay
            .drive(view.showErrorToast)
            .disposed(by: bag)

        output.indicatorDisplay
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: bag)

        output.isFavorite
            .drive(favorteBtn.rx.isSelected)
            .disposed(by: bag)

        output.config
            .drive()
            .disposed(by: bag)
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(indicatorView)

        indicatorView.snp.makeConstraints({
            $0.center.equalToSuperview()
        })

        let pokemonContenView = UIStackView(frame: .zero)
        pokemonContenView.axis = .vertical
        pokemonContenView.distribution = .fillProportionally
        pokemonContenView.alignment = .center
        pokemonContenView.addArrangedSubview(imageView)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        pokemonContenView.addArrangedSubview(idLabel)
        pokemonContenView.addArrangedSubview(nameLabel)
        pokemonContenView.addArrangedSubview(typeslabel)
        pokemonContenView.addArrangedSubview(descriptionlabel)

        view.addSubview(pokemonContenView)

        pokemonContenView.snp.makeConstraints({
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(8)
        })

        view.addSubview(collectionview)
        collectionview.snp.makeConstraints({
            $0.top.equalTo(pokemonContenView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        })
    }

    private var infoDisplay: Binder<PMInfoDisplayable> {
        return .init(self, binding: { _self, info in
            _self.nameLabel.text = info.nameTitle
            _self.idLabel.text = info.idTitle
            _self.typeslabel.text = info.typesTitle
            _self.imageView.downLaodImageWith(url: info.imgurl)
        })
    }

    private var desDisplay: Binder<String> {
        return .init(self, binding: { _self, info in
            _self.descriptionlabel.isHidden = info.isEmpty
            _self.descriptionlabel.text = info
        })
    }

    private var chainDisplay: Binder<[PMCellDisplayable]> {
        return .init(self, binding: { _self, info in
            _self.dataDisplay = info
            _self.view.layoutIfNeeded()
            _self.collectionview.reloadData()
        })
    }

    deinit {
        print("PMDetialVC deinit")
    }
}

// MARK: UICollectionViewDelegate
extension PMDetialVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemSelected.accept(indexPath)
    }
}

// MARK: UICollectionViewDataSource
extension PMDetialVC: UICollectionViewDataSource {
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
