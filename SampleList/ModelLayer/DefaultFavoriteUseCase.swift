//
//  DefaultFavoritUseCase.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/9.
//

import Foundation
import RxSwift

class DefaultFavoriteUseCase {
    private let favoriteRepo: FavoriteRepoProtocol

    init(favoriteRepo: FavoriteRepoProtocol = FavoriteRepo.shared) {
        self.favoriteRepo = favoriteRepo
    }

    func favoriteState(name: String) -> Bool {
        return favoriteRepo.isFavorite(name: name)
    }

    func favoirteToggle(name: String) -> Observable<Bool> {
        if favoriteState(name: name) {
            return .just(favoriteRepo.deleteFavorte(name: name))
        } else {
            return .just(favoriteRepo.addFavotite(name: name))
        }
    }
}
