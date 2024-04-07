//
//  PMListCellViewModel.swift
//  SampleList
//
//  Created by chiayu Yen on 2024/4/8.
//

import Foundation
import RxCocoa
import RxSwift

class PMCellViemModel {
    struct Input {
        let sourceChanged: Driver<String>
    }

    struct Output {
        let infoChanged: Driver<PokemonInfo?>
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
        return .init(infoChanged: fetchdata,
                     indicator: indicatorTracker.asDriver(onErrorJustReturn: false))
    }
}
