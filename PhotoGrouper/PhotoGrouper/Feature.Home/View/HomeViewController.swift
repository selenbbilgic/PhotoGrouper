//
//  HomeViewController.swift
//  PhotoGrouper
//
//  Created by selen bilgiç on 22.08.2025.
//

import UIKit
import SwiftUI

final class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"

         navigationItem.rightBarButtonItem = UIBarButtonItem(
             title: "Open",
             style: .plain,
             target: self,
             action: #selector(openGroupDetail)
         )
    }

     @objc private func openGroupDetail() {
         let hosting = UIHostingController(rootView: GroupDetailView())
         navigationController?.pushViewController(hosting, animated: true)
     }
}
