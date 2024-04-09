//
//  PMDetailVM.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/9.
//

import Foundation
import RxCocoa
import RxSwift

class PMDetailVM {
    private let name: String
    private let favoriteUseCase: DefaultFavoriteUseCase
    private let infoUseCase: DefaultPMInfoUseCase
    private let coordinator: PMDetialCoordinator

    struct Input {
        let viewAppear: Driver<Bool>
        let favoriteClick: Driver<Void>
        let showPokemon: Driver<IndexPath>
    }

    struct Output {
        let pokemonInfo: Driver<PMInfoDisplayable>
        let description: Driver<String>
        let chain: Driver<[PMCellDisplayable]>
        let indicatorDisplay: Driver<Bool>
        let errorDisplay: Driver<ErrorDisplay?>
        let isFavorite: Driver<Bool>
        let config: Driver<Void>
    }

    init(name: String,
         coordinator: PMDetialCoordinator,
         favoriteUseCase: DefaultFavoriteUseCase = .init(),
         infoUseCase: DefaultPMInfoUseCase = .init()
    ) {
        self.name = name
        self.favoriteUseCase = favoriteUseCase
        self.infoUseCase = infoUseCase
        self.coordinator = coordinator
    }

    deinit {
        print("PMDetailVM deinit")
    }

    func trasfrom(input: Input) -> Output {
        let indicatorOutput = PublishRelay<Bool>()
        let errorOutput = PublishRelay<Error?>()

        let viewIsShowUp = input.viewAppear
            .filter({ $0 })
            .mapToVoid()

        let fetchPokemonInfo = viewIsShowUp
            .flatMapLatest({ [weak self] _ -> Driver<PokemonInfo> in
                guard let self else { return .empty() }
                return self.infoUseCase.fetchInfoWith(name: self.name)
                    .trackIndicator(indicator: indicatorOutput)
                    .trackError(errorRelay: errorOutput)
                    .asDriver(onErrorDriveWith: .empty())
            })

        let fetchSpecies = viewIsShowUp
            .flatMapLatest({ [weak self] _ -> Driver<PokemonSpecies?> in
                guard let self else { return .empty() }
                return self.infoUseCase.fetchSpecies(name: self.name)
                    .mapToOptional()
                    .trackIndicator(indicator: indicatorOutput)
                    .trackError(errorRelay: errorOutput)
                    .asDriver(onErrorDriveWith: .empty())
            })

        let description = fetchSpecies.map({ info -> String in
            guard let info else { return "" }
            return info.getPreferredFromDesctiption()
        })

        let evolutionChain = fetchSpecies.flatMapLatest({ [weak self] info -> Driver<[EvolutionChain.Species]> in
            guard let self, let evolutionUrl = info?.evolutionChain?.url else { return .just([]) }
            return self.infoUseCase.fetchEvolutionChain(url: evolutionUrl)
                .map({ $0.flatMapChain() })
                .trackIndicator(indicator: indicatorOutput)
                .trackError(errorRelay: errorOutput)
                .asDriver(onErrorJustReturn: [])
        })

        let showPokemon = input.showPokemon
            .withLatestFrom(evolutionChain, resultSelector: { indexPath, infos in
                return infos[indexPath.row].name
            })
            .do(onNext: { [weak self] name in
                self?.coordinator.toOtherDetail(name: name)
            })

        let favoriteClick = input.favoriteClick
            .flatMapLatest({ [weak favoriteUseCase, weak self] _ -> Driver<Void> in
                guard let self, let favoriteUseCase else { return .empty() }
                return favoriteUseCase.favoirteToggle(name: self.name)
                    .trackIndicator(indicator: indicatorOutput)
                    .asDriver(onErrorDriveWith: .empty())
            })

        let checkFavoritState = viewIsShowUp
            .flatMapLatest({ [weak favoriteUseCase, weak self] _ -> Driver<Bool> in
                guard let self, let favoriteUseCase else { return .empty() }
                return favoriteUseCase.favoriteState(name: self.name)
                    .asDriver(onErrorDriveWith: .empty())
            })

        return .init(pokemonInfo: fetchPokemonInfo.map(\.display),
                     description: description,
                     chain: evolutionChain.map({ $0.map(\.display) }),
                     indicatorDisplay: indicatorOutput.asDriver(onErrorJustReturn: false),
                     errorDisplay: errorOutput.map({ $0?.covertToDisplayError() }).asDriver(onErrorJustReturn: nil),
                     isFavorite: .merge(checkFavoritState),
                     config: .merge(showPokemon.mapToVoid(), favoriteClick)
        )
    }
}
