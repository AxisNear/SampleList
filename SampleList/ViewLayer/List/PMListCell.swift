//
//  PMListCell.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import SnapKit
import UIKit

class PMListCell: UICollectionViewCell {
    static let cellID = "PMListCell"
    let nameLabel = UILabel()
    let imageView = UIImageView()
    let idLabel = UILabel()
    let typeslabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
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

        imageView.snp.makeConstraints({
            $0.width.height.equalTo(70)
            $0.top.leading.equalToSuperview().inset(5)
            $0.trailing.equalTo(contentStakeView.snp.leading).offset(-8)
        })

        contentStakeView.snp.makeConstraints({
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
        })
        imageView.backgroundColor = .lightGray
        nameLabel.numberOfLines = 1
        idLabel.numberOfLines = 1
        typeslabel.numberOfLines = 1
        #if DEBUG
            nameLabel.text = "nameTest"
            idLabel.text = "idTest"
            typeslabel.text = "TypesTest"
        #endif
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        idLabel.text = ""
        typeslabel.text = ""
        imageView.image = nil
        imageView.cancelDownloadImage()
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
