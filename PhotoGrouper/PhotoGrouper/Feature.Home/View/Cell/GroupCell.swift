//
//  GroupCell.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//


import UIKit

final class GroupCell: UICollectionViewCell {
    static let reuseId = "GroupCell"
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let countBadge = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(with item: GroupDisplay) {
        titleLabel.text = item.title
        countBadge.text = "\(item.count)"
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        contentView.addSubview(container)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        countBadge.translatesAutoresizingMaskIntoConstraints = false
        countBadge.font = .systemFont(ofSize: 13, weight: .bold)
        countBadge.textColor = .white
        countBadge.backgroundColor = .systemPink
        countBadge.textAlignment = .center
        countBadge.layer.cornerRadius = 12
        countBadge.layer.masksToBounds = true
        countBadge.setContentHuggingPriority(.required, for: .horizontal)
        countBadge.setContentCompressionResistancePriority(.required, for: .horizontal)

        container.addSubview(titleLabel)
        container.addSubview(countBadge)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countBadge.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            countBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            countBadge.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            countBadge.heightAnchor.constraint(equalToConstant: 24),
            countBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 28)
        ])
    }
    
}
