//
//  FavoriteRepo.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import Foundation
import RxSwift

protocol FavoriteRepoProtocol {
    func addFavotite(name: String) -> Bool
    func deleteFavorte(name: String) -> Bool
    func getFavortie(name: String) -> Bool
}

class FavoriteRepo: FavoriteRepoProtocol {
    private var favoriteList: Set<String>
    static var shared = FavoriteRepo()
    private let storeKey = "favoriteList"

    init(favoriteList: Set<String>? = nil) {
        if let favoriteList {
            self.favoriteList = favoriteList
        } else {
            let localRecord = UserDefaults.standard.array(forKey: storeKey) as? [String]
            self.favoriteList = Set<String>(localRecord ?? [])
        }
    }

    func addFavotite(name: String) -> Bool {
        favoriteList.insert(name)
        syncToDefault()
        return true
    }

    func deleteFavorte(name: String) -> Bool {
        favoriteList.remove(name)
        syncToDefault()
        return false
    }

    func getFavortie(name: String) -> Bool {
        return favoriteList.contains(name)
    }

    func syncToDefault() {
        UserDefaults.standard.setValue(Array(favoriteList), forKey: storeKey)
    }
}
