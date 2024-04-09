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

    let useCase: DefaultPMInfoUseCase
    let favroiteUseCase: DefaultFavoriteUseCase

    init(useCase: DefaultPMInfoUseCase = DefaultPMInfoUseCase(),
         favortieUseCase: DefaultFavoriteUseCase = DefaultFavoriteUseCase()) {
        self.useCase = useCase
        self.favroiteUseCase = favortieUseCase
    }

    func trasfrom(input: Input) -> Output {
        let indicatorTracker: PublishRelay<Bool> = .init()
        let fetchdata = input.sourceChanged
            .flatMapLatest({ [weak useCase] name -> Driver<PokemonInfo?> in
                guard let useCase else { return .empty() }
                return useCase.fetchInfoWith(name: name)
                    .mapToOptional()
                    .trackIndicator(indicator: indicatorTracker)
                    .asDriver(onErrorJustReturn: nil)
            })

        let favoriteEvnet = input.favoriteClick
            .flatMapLatest({ [weak favroiteUseCase] name -> Driver<Bool> in
                guard let favroiteUseCase else { return .empty() }
                return favroiteUseCase.favoirteToggle(name: name)
                    .trackIndicator(indicator: indicatorTracker)
                    .asDriver(onErrorDriveWith: .empty())
            })

        let checkFavoritState = input.sourceChanged
            .map({ [weak favroiteUseCase] name -> Bool in
                guard let favroiteUseCase else { return false }
                return favroiteUseCase.favoriteState(name: name)
            })
        return .init(infoChanged: fetchdata,
                     isFavorite: .merge(favoriteEvnet, checkFavoritState),
                     indicator: indicatorTracker.asDriver(onErrorJustReturn: false))
    }
}
