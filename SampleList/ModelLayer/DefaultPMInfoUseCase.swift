//
//  DefaultPMCellUseCase.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import Foundation
import RxSwift

class DefaultPMInfoUseCase {
    let repo: PMRemoteRepoProtocol

    init(repo: PMRemoteRepoProtocol = PMRemoteRepo()) {
        self.repo = repo
    }

    func fetchInfoWith(name: String) -> Observable<PokemonInfo> {
        return repo.fetchPokemonInfoForm(name: name)
    }
}
