//
//  DefaultPMCellUseCase.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import Foundation
import RxSwift

class DefaultPMCellUseCase {
    let repo: PMRemoteRepoProtocol
    let favoriteRepo: FavoriteRepoProtocol
    init(repo: PMRemoteRepoProtocol = PMRemoteRepo(), favortieRepo: FavoriteRepoProtocol = FavoriteRepo.shared) {
        self.repo = repo
        self.favoriteRepo = favortieRepo
    }

    func fetchInfoWith(name: String) -> Observable<PokemonInfo> {
        return repo.fetchPokemonInfoForm(name: name)
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
