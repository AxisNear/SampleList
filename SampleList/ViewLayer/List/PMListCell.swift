//
//  PMListCell.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class PMListCell: UICollectionViewCell {
    static let cellID = "PMListCell"
    private let nameLabel = UILabel()
    private let imageView = UIImageView()
    private let idLabel = UILabel()
    private let typeslabel = UILabel()
    private let viewModel: PMListCellVM = .init()
    private let bag = DisposeBag()
    private let sourceChanged: PublishRelay<String> = .init()
    private var pokemonName: String = ""
    private let favorteBtn: UIButton = UIFactory.createFavoriteBtn()
    private let indicator: UIActivityIndicatorView = UIFactory.createIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindEvent()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        bindEvent()
    }

    func config(with cellDisplay: PMCellDisplayable) {
        pokemonName = cellDisplay.name
        sourceChanged.accept(cellDisplay.name)
    }

    private func setupUI() {
        contentView.addSubview(indicator)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(typeslabel)
        contentView.addSubview(imageView)
        contentView.addSubview(favorteBtn)

        let contentStakeView = UIStackView(frame: .zero)
        contentStakeView.axis = .vertical
        contentStakeView.distribution = .fillEqually
        contentStakeView.alignment = .leading
        contentView.addSubview(contentStakeView)
        contentStakeView.addArrangedSubview(idLabel)
        contentStakeView.addArrangedSubview(nameLabel)
        contentStakeView.addArrangedSubview(typeslabel)

        indicator.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
        })

        imageView.snp.makeConstraints({
            $0.width.height.equalTo(70)
            $0.top.equalToSuperview().inset(5)
            $0.leading.equalTo(indicator.snp.trailing).offset(8)
        })

        contentStakeView.snp.makeConstraints({
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.top.bottom.equalToSuperview()
        })

        favorteBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        favorteBtn.setContentHuggingPriority(.required, for: .horizontal)
        favorteBtn.snp.makeConstraints({
            $0.width.height.equalTo(50)
            $0.leading.equalTo(contentStakeView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
        })

        imageView.backgroundColor = .lightGray
        nameLabel.numberOfLines = 1
        idLabel.numberOfLines = 1
        typeslabel.numberOfLines = 1
    }

    private func bindEvent() {
        let btnClick = favorteBtn.rx.controlEvent(.touchUpInside)
            .withUnretained(self)
            .map({ _self, _ in
                return _self.pokemonName
            })
            .asDriver(onErrorDriveWith: .empty())

        let output = viewModel.trasfrom(input: .init(sourceChanged: sourceChanged.asDriver(onErrorJustReturn: ""),
                                                     favoriteClick: btnClick))

        let prepareReuse: Driver<PMInfoDisplayable?> = rx.methodInvoked(#selector(prepareForReuse))
            .asDriver(onErrorDriveWith: .empty())
            .map({ _ in return nil })

        let fetchInfo = output.infoChanged
        Driver.merge(prepareReuse, fetchInfo)
            .drive(infoDisplay)
            .disposed(by: bag)

        output.indicator
            .drive(indicator.rx.isAnimating)
            .disposed(by: bag)

        output.isFavorite
            .drive(favorteBtn.rx.isSelected)
            .disposed(by: bag)

        output.config
            .drive()
            .disposed(by: bag)
    }

    private var infoDisplay: Binder<PMInfoDisplayable?> {
        return .init(self, binding: { _weakSelf, info in
            if let info {
                _weakSelf.nameLabel.text = info.nameTitle
                _weakSelf.idLabel.text = info.idTitle
                _weakSelf.typeslabel.text = info.typesTitle
                _weakSelf.imageView.downLaodImageWith(url: info.imgurl)
            } else {
                _weakSelf.nameLabel.text = ""
                _weakSelf.idLabel.text = ""
                _weakSelf.typeslabel.text = ""
                _weakSelf.imageView.image = nil
                _weakSelf.imageView.cancelDownloadImage()
            }
        })
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let preferred = super.preferredLayoutAttributesFitting(layoutAttributes)
        var modifyRect = preferred.frame

        modifyRect.size = contentView.systemLayoutSizeFitting(CGSize(width: window?.bounds.width ?? 300, height: 80),
                                                              withHorizontalFittingPriority: .defaultHigh,
                                                              verticalFittingPriority: .defaultHigh)
        preferred.frame = modifyRect
        return preferred
    }
}
