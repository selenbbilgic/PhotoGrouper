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
    
    private let viewModel = HomeViewModel()
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, GroupDisplay>!
    
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let progressLabel = UILabel()

    private var items: [GroupDisplay] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Groups"

        configureProgressHeader()
        configureCollectionView()
        configureDataSource()
        bindViewModel()
        applySnapshot(animatingDifferences: false)

        viewModel.startScan()
    }
    
    private func configureProgressHeader() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.translatesAutoresizingMaskIntoConstraints = false

        progressLabel.font = .systemFont(ofSize: 13, weight: .medium)
        progressLabel.textColor = .secondaryLabel
        progressLabel.textAlignment = .left            // center text too

        // Optional: make the bar easier to see
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .tertiarySystemFill

        view.addSubview(progressView)
        view.addSubview(progressLabel)

        NSLayoutConstraint.activate([
            // progress bar centered horizontally with 60% width
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            progressView.heightAnchor.constraint(equalToConstant: 4),

            // label centered under the bar
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor)
        ])
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
            collectionView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 12),
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
    
    private func bindViewModel() {
        viewModel.onOutput = { [weak self] output in
            guard let self else { return }
            self.items = output.displays
            self.applySnapshot()
            self.progressView.setProgress(Float(output.percent), animated: true)
            self.progressLabel.text = "Scanning photos: \(Int(output.percent * 100))% (\(output.processed)/\(output.total))"
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = item(at: indexPath) else {return}
        let ids = viewModel.assetIDs(for: item)

        guard !ids.isEmpty else {
            let alert = UIAlertController(title: "No photos yet",
                                          message: "This group is still scanning or has no visible items.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let view = GroupDetailView(groupTitle: item.title, assetIDs: ids)
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
