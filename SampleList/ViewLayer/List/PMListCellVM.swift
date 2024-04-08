//
//  PMListCellViewModel.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import Foundation
import RxCocoa
import RxSwift

class PMListCellVM {
    struct Input {
        let sourceChanged: Driver<String>
        let favoriteClick: Driver<String>
    }

    struct Output {
        let infoChanged: Driver<PokemonInfo?>
        let isFavorite: Driver<Bool>
        let indicator: Driver<Bool>
    }

    let useCase: DefaultPMCellUseCase

    init(useCase: DefaultPMCellUseCase = DefaultPMCellUseCase()) {
        self.useCase = useCase
    }

    func trasfrom(input: Input) -> Output {
        let indicatorTracker: PublishRelay<Bool> = .init()
        let fetchdata = input.sourceChanged
            .flatMapLatest({ [weak useCase] name -> Driver<PokemonInfo?> in
                guard let useCase else { return .empty() }
                return useCase.fetchInfoWith(name: name)
                    .trackIndicator(indicator: indicatorTracker)
                    .map({ info -> PokemonInfo? in return info })
                    .asDriver(onErrorJustReturn: nil)
            })

        let favoriteEvnet = input.favoriteClick
            .flatMapLatest({ [weak useCase] name -> Driver<Bool> in
                guard let useCase else { return .empty() }
                return useCase.favoirteToggle(name: name)
                    .trackIndicator(indicator: indicatorTracker)
                    .asDriver(onErrorDriveWith: .empty())
            })

        let checkFavoritState = input.sourceChanged
            .map({ [weak useCase] name -> Bool in
                guard let useCase else { return false }
                return useCase.favoriteState(name: name)
            })
        return .init(infoChanged: fetchdata,
                     isFavorite: .merge(favoriteEvnet, checkFavoritState),
                     indicator: indicatorTracker.asDriver(onErrorJustReturn: false))
    }
}
