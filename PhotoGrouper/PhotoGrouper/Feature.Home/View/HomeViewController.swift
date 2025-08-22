//
//  HomeViewController.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import UIKit
import SwiftUI

final class HomeViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, GroupDisplay>!
    private var items: [GroupDisplay] = [
        GroupDisplay(title: "G1", count: 5),
        GroupDisplay(title: "G2", count: 10),
        GroupDisplay(title: "G3", count: 15),
        GroupDisplay(title: "others", count: 8)
    ].filter {$0.count > 0}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Groups"

        configureCollectionView()
        configureDataSource()
        applySnapshot(animatingDifferences: false)
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: GroupCell.reuseId)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, GroupDisplay>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCell.reuseId, for: indexPath) as! GroupCell
            cell.configure(with: item)
            return cell
        }
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, GroupDisplay>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func item(at indexPath: IndexPath) -> GroupDisplay? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = item(at: indexPath) else {return}
        let mochPhotos = SamplePhoto.mock(count: 4)
        let view = GroupDetailView(groupTitle: item.title, photos: mochPhotos)
        let hosting = UIHostingController(rootView: view)
        navigationController?.pushViewController(hosting, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = traitCollection.horizontalSizeClass == .compact ? 2 : 4
                let inset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? .zero
                let spacing = (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
                let totalSpacing = inset.left + inset.right + spacing * (columns - 1)
                let width = floor((collectionView.bounds.width - totalSpacing) / columns)
                return CGSize(width: width, height: 72)
    }
}
