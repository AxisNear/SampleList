//
//  PokemonListViewModel.swift
//  SampleList
//

import Foundation
import RxCocoa
import RxSwift

class PMListViewModel {
    enum ListLayout {
        case listStle, gridStyle
    }

    struct ScrollInfo {
        let offst: CGPoint
        let contentSize: CGSize
    }

    struct Input {
        let isViewAppear: Driver<Bool>
        let scrollInfo: Driver<ScrollInfo>
        let refresh: Driver<Void>
        let switchClick: Driver<Void>
        let favriateClick: Driver<Void>
    }

    struct Output {
        let dataChanged: Driver<[any PMCellDisplayable]>
        let indicator: Driver<Bool>
        let errorDisplay: Driver<ErrorDisplay?>
        let layoutSwitch: Driver<ListLayout>
    }

    let useCase: PokemonListUseCaseProtocol
    let loadmoreOffset: CGFloat

    init(useCase: PokemonListUseCaseProtocol = DefaultPMListUseCase(), loadMoreOffset: CGFloat = 300) {
        self.useCase = useCase
        self.loadmoreOffset = loadMoreOffset
    }

    func transfrom(input: Input) -> Output {
        let errorOutput: PublishRelay<Error?> = .init()
        let indicatorOuput: PublishRelay<Bool> = .init()
        let fetchWhenDataEmpty = input.isViewAppear
            .filter({ $0 == true })
            .flatMapLatest({ [weak self] _ -> Driver<[PokemonList.PokemonSource]> in
                guard let self else { return .empty() }
                return self.useCase.fetchIfEmpty()
                    .trackError(errorRelay: errorOutput)
                    .trackIndicator(indicator: indicatorOuput)
                    .asDriver(onErrorJustReturn: .init())
            })

        let refresh = input.refresh
            .flatMapLatest({ [weak self] _ -> Driver<[PokemonList.PokemonSource]> in
                guard let self else { return .empty() }
                return self.useCase.refresh()
                    .trackError(errorRelay: errorOutput)
                    .trackIndicator(indicator: indicatorOuput)
                    .asDriver(onErrorJustReturn: .init())
            })

        let _loadMoreOffset = loadmoreOffset

        let loadMore = input.scrollInfo.filter({ scrollInfo in
            return scrollInfo.offst.y > (scrollInfo.contentSize.height - _loadMoreOffset)
        }).flatMapLatest({ [weak self] _ -> Driver<[PokemonList.PokemonSource]> in
            guard let self else { return .empty() }
            return self.useCase.loadmore()
                .trackError(errorRelay: errorOutput)
                .trackIndicator(indicator: indicatorOuput)
                .asDriver(onErrorJustReturn: .init())
        })

        let dataChanged = Driver.merge(fetchWhenDataEmpty, refresh, loadMore)
            .map(transDataToDisplayModel(pokemonSource:))

        return .init(dataChanged: dataChanged,
                     indicator: indicatorOuput.asDriver(onErrorJustReturn: false),
                     errorDisplay: errorOutput.map({ $0?.covertToDisplayError() }).asDriver(onErrorJustReturn: nil),
                     layoutSwitch: .empty()
        )
    }

    private func transDataToDisplayModel(pokemonSource: [PokemonList.PokemonSource]) -> [any PMCellDisplayable] {
        return pokemonSource
    }
}

protocol PMCellDisplayable {
    var name: String { get }
    var url: String { get }
}

// MARK: - PMCellDisplayable
extension PokemonList.PokemonSource: PMCellDisplayable {}
