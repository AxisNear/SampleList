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
    let nameLabel = UILabel()
    let imageView = UIImageView()
    let idLabel = UILabel()
    let typeslabel = UILabel()
    let viewModel: PMCellViemModel = .init()
    let bag = DisposeBag()
    let sourceChanged: PublishRelay<String> = .init()
    let indicator: UIActivityIndicatorView = {
        let _indicator = UIActivityIndicatorView(style: .medium)
        _indicator.hidesWhenStopped = true
        _indicator.color = .gray
        return _indicator
    }()

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
        nameLabel.text = cellDisplay.name
        sourceChanged.accept(cellDisplay.name)
    }

    private func setupUI() {
        contentView.addSubview(indicator)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(typeslabel)
        contentView.addSubview(imageView)

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
            $0.trailing.equalToSuperview().inset(8)
        })

        imageView.backgroundColor = .lightGray
        nameLabel.numberOfLines = 1
        idLabel.numberOfLines = 1
        typeslabel.numberOfLines = 1
    }

    private func bindEvent() {
        let output = viewModel.trasfrom(input: .init(sourceChanged: sourceChanged.asDriver(onErrorJustReturn: "")))

        let prepareReuse: Driver<PokemonInfo?> = rx.methodInvoked(#selector(prepareForReuse))
            .asDriver(onErrorDriveWith: .empty())
            .map({ _ in return nil })

        let fetchInfo = output.infoChanged
        Driver.merge(prepareReuse, fetchInfo)
            .drive(infoDisplay)
            .disposed(by: bag)

        output.indicator
            .drive(indicator.rx.isAnimating)
            .disposed(by: bag)
    }

    private var infoDisplay: Binder<PokemonInfo?> {
        return .init(self, binding: { _weakSelf, info in
            if let info {
                _weakSelf.nameLabel.text = "name: " + info.name
                _weakSelf.idLabel.text = "id: \(info.id)"
                _weakSelf.typeslabel.text = "type: " + info.types.joined(separator: ", ")
                _weakSelf.imageView.downLaodImageWith(url: info.thumbnail)
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
        modifyRect.size = contentView.systemLayoutSizeFitting(CGSize(width: UIScreen.main.bounds.width, height: 80),
                                                              withHorizontalFittingPriority: .defaultHigh,
                                                              verticalFittingPriority: .defaultHigh)
        preferred.frame = modifyRect
        return preferred
    }
}
