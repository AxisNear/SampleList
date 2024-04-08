//
//  FavoriteRepo.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import Foundation
import RxSwift

protocol FavoriteRepoProtocol {
    var favoriteList: [String] { get }

    func addFavotite(name: String) -> Bool
    func deleteFavorte(name: String) -> Bool
    func isFavorite(name: String) -> Bool
}

class FavoriteRepo: FavoriteRepoProtocol {
    private(set) var favoriteList: [String]
    static var shared = FavoriteRepo()
    private let storeKey = "favoriteList"
    private var willResignObserver: NSObjectProtocol?

    init(favoriteList: [String]? = nil) {
        if let favoriteList {
            self.favoriteList = favoriteList
        } else {
            let localRecord = UserDefaults.standard.array(forKey: storeKey) as? [String]
            self.favoriteList = localRecord ?? []
        }

        willResignObserver = NotificationCenter.default
            .addObserver(forName: UIApplication.willResignActiveNotification,
                         object: nil,
                         queue: nil,
                         using: { [weak self] _ in
                             self?.syncToDefault()
                         })
    }

    func addFavotite(name: String) -> Bool {
        favoriteList.insert(name, at: 0)
        return true
    }

    func deleteFavorte(name: String) -> Bool {
        favoriteList.removeAll(where: { $0 == name })
        return false
    }

    func isFavorite(name: String) -> Bool {
        return favoriteList.contains(name)
    }

    func syncToDefault() {
        UserDefaults.standard.setValue(favoriteList, forKey: storeKey)
    }

    deinit {
        if let willResignObserver {
            NotificationCenter.default.removeObserver(willResignObserver)
        }
    }
}
