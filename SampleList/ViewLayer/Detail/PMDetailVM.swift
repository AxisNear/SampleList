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
    private let favoritUseCase: DefaultFavoriteUseCase
    private let infoUseCase: DefaultPMInfoUseCase

    struct Input {
        let viewAppear: Driver<Bool>
    }

    struct Output {
        let pokemonInfo: Driver<PokemonInfo>
        let description: Driver<String>
        let chain: Driver<[String]>
        let indicatorDisplay: Driver<Bool>
        let errorDisplay: Driver<ErrorDisplay?>
    }

    init(name: String,
         favoriteUseCase: DefaultFavoriteUseCase = .init(),
         infoUseCase: DefaultPMInfoUseCase = .init()) {
        self.name = name
        self.favoritUseCase = favoriteUseCase
        self.infoUseCase = infoUseCase
    }

    func trasfrom(input: Input) -> Output {
        let indicatorOutput = PublishRelay<Bool>()
        let errorOutput = PublishRelay<Error?>()
        let viewIsShowUp = input.viewAppear.filter({ $0 })
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

        let evolutionChain = fetchSpecies.flatMapLatest({ [weak self] info -> Driver<[String]> in
            guard let self, let evolutionUrl = info?.evolutionChain?.url else { return .just([]) }
            return self.infoUseCase.fetchEvolutionChain(url: evolutionUrl)
                .map({ $0.flatMapChain().map(\.name) })
                .trackIndicator(indicator: indicatorOutput)
                .trackError(errorRelay: errorOutput)
                .asDriver(onErrorJustReturn: [])
        })

        return .init(pokemonInfo: fetchPokemonInfo.compactMap({ $0 }),
                     description: description,
                     chain: evolutionChain,
                     indicatorDisplay: indicatorOutput.asDriver(onErrorJustReturn: false),
                     errorDisplay: errorOutput.map({ $0?.covertToDisplayError() }).asDriver(onErrorJustReturn: nil)
        )
    }
}
