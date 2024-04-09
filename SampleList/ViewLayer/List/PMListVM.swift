//
//  PokemonListViewModel.swift
//  SampleList
//

import Foundation
import RxCocoa
import RxSwift

class PMListVM {
    enum ListLayout {
        case listStle, gridStyle
    }

    struct ScrollInfo {
        let offst: CGPoint
        let contentSize: CGSize
        let boundSize: CGSize

        static func zero() -> Self {
            return .init(offst: .zero, contentSize: .zero, boundSize: .zero)
        }
    }

    struct Input {
        let isViewAppear: Driver<Bool>
        let scrollInfo: Driver<ScrollInfo>
        let refresh: Driver<Void>
        let switchClick: Driver<Void>
        let favriateSwitch: Driver<Void>
        let itemSelected: Driver<IndexPath>
    }

    struct Output {
        let dataChanged: Driver<[any PMCellDisplayable]>
        let indicator: Driver<Bool>
        let errorDisplay: Driver<ErrorDisplay?>
        let layoutSwitch: Driver<ListLayout>
        let config: Driver<Void>
    }

    private let useCase: PokemonListUseCaseProtocol
    private let loadmoreOffset: CGFloat
    private var coordinator: PMListCoordinator

    init(coordinator: PMListCoordinator,
         useCase: PokemonListUseCaseProtocol = DefaultPMListUseCase(),
         loadMoreOffset: CGFloat = 100) {
        self.useCase = useCase
        self.loadmoreOffset = loadMoreOffset
        self.coordinator = coordinator
    }

    deinit {
        print("PMListVM deinit")
    }

    func transfrom(input: Input) -> Output {
        let errorOutput: PublishRelay<Error?> = .init()
        let indicatorOuput: PublishRelay<Bool> = .init()
        let fetchWhenDataEmpty = input.isViewAppear
            .filter({ $0 == true })
            .flatMapLatest({ [weak self] _ -> Driver<[PokemonList.PokemonSource]> in
                guard let self else { return .empty() }
                return self.useCase.fetchIfNeed()
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
            guard scrollInfo.boundSize != .zero,
                  scrollInfo.offst.y > 0,
                  scrollInfo.contentSize != .zero else {
                return false
            }
            return scrollInfo.offst.y > (scrollInfo.contentSize.height - scrollInfo.boundSize.height - _loadMoreOffset)
        }).flatMapLatest({ [weak self] _ -> Driver<[PokemonList.PokemonSource]> in
            guard let self else { return .empty() }
            return self.useCase.loadmore()
                .trackError(errorRelay: errorOutput)
                .trackIndicator(indicator: indicatorOuput)
                .asDriver(onErrorJustReturn: .init())
        })

        let favoriteSwitch = input.favriateSwitch
            .flatMapLatest({ [weak self] _ -> Driver<[PokemonList.PokemonSource]> in
                guard let self else { return .empty() }
                return self.useCase.toggleFavoriteMode()
                    .asDriver(onErrorJustReturn: [])
            })
        let dataChanged = Driver.merge(fetchWhenDataEmpty, refresh, loadMore, favoriteSwitch)

        let showDetial = input.itemSelected
            .withLatestFrom(dataChanged, resultSelector: { _indexPath, sources in
                return sources[_indexPath.row]
            })
            .do(onNext: { [weak coordinator] item in
                coordinator?.showDetial(name: item.name)
            })
            .mapToVoid()

        return .init(dataChanged: dataChanged.map(transDataToDisplayModel(pokemonSource:)),
                     indicator: indicatorOuput.asDriver(onErrorJustReturn: false),
                     errorDisplay: errorOutput.map({ $0?.covertToDisplayError() }).asDriver(onErrorJustReturn: nil),
                     layoutSwitch: .empty(),
                     config: .merge(showDetial)
        )
    }

    private func transDataToDisplayModel(pokemonSource: [PokemonList.PokemonSource]) -> [any PMCellDisplayable] {
        return pokemonSource
    }
}
