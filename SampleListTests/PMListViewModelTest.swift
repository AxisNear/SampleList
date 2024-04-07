//
//  PKListViewModelTest.swift
//  SampleListTests
//
//  Created by chiayu Yen on 2024/4/7.
//

@testable import RxSwift
import RxTest
@testable import SampleList
import XCTest

final class PMListViewModelTest: XCTestCase {
    var scheduler: TestScheduler!
    private var fakeUseCase: FakeListUseCase!
    override func setUp() {
        super.setUp()
        scheduler = .init(initialClock: 0)
        fakeUseCase = FakeListUseCase()
    }

    func testFetchIfEmpty() {
        let mockViewIsAppear = scheduler.createColdObservable([
            .next(1, true),
            .next(2, false)
        ]).asDriver(onErrorDriveWith: .empty())

        let vm = PMListViewModel(useCase: fakeUseCase)
        let output = vm.transfrom(input: .init(isViewAppear: mockViewIsAppear,
                                               scrollInfo: .empty(),
                                               refresh: .empty(),
                                               switchClick: .empty(),
                                               favriateClick: .empty()))

        let observer = scheduler.createObserver([any PMCellDisplayable].self)
        let bag = DisposeBag()

        output.dataChanged
            .drive(observer)
            .disposed(by: bag)

        scheduler.start()
        let result = observer.events.map(\.time)
        XCTAssertEqual(result, [1])
    }

    func testRefresh() {
        let refresh = scheduler.createColdObservable([
            .next(1, ()),
            .next(2, ())
        ]).asDriver(onErrorDriveWith: .empty())

        let vm = PMListViewModel(useCase: fakeUseCase)
        let output = vm.transfrom(input: .init(isViewAppear: .empty(),
                                               scrollInfo: .empty(),
                                               refresh: refresh,
                                               switchClick: .empty(),
                                               favriateClick: .empty()))

        let observer = scheduler.createObserver([any PMCellDisplayable].self)
        let bag = DisposeBag()

        output.dataChanged
            .drive(observer)
            .disposed(by: bag)

        scheduler.start()
        let result = observer.events.map(\.time)
        XCTAssertEqual(result, [1, 2])
    }

    func testLoadMore() {
        typealias ScrollInfo = PMListViewModel.ScrollInfo
        let offset = scheduler.createColdObservable([
            .next(0, ScrollInfo(offst: CGPoint(x: 0, y: 0), contentSize: CGSize(width: 100, height: 1000))),
            .next(1, ScrollInfo(offst: CGPoint(x: 0, y: 200), contentSize: CGSize(width: 100, height: 1000))),
            .next(2, ScrollInfo(offst: CGPoint(x: 0, y: 400), contentSize: CGSize(width: 100, height: 1000))),
            .next(3, ScrollInfo(offst: CGPoint(x: 0, y: 600), contentSize: CGSize(width: 100, height: 1000))),
            .next(4, ScrollInfo(offst: CGPoint(x: 0, y: 800), contentSize: CGSize(width: 100, height: 2000)))
        ]).asDriver(onErrorDriveWith: .empty())

        let vm = PMListViewModel(useCase: fakeUseCase, loadMoreOffset: 500)
        let output = vm.transfrom(input: .init(isViewAppear: .empty(),
                                               scrollInfo: offset,
                                               refresh: .empty(),
                                               switchClick: .empty(),
                                               favriateClick: .empty()))

        let observer = scheduler.createObserver([any PMCellDisplayable].self)
        let bag = DisposeBag()

        output.dataChanged
            .drive(observer)
            .disposed(by: bag)

        scheduler.start()
        let result = observer.events.map(\.time)
        XCTAssertEqual(result, [3])
    }
}

private class FakeListUseCase: PokemonListUseCaseProtocol {
    var pokemonSources: [SampleList.PokemonList.PokemonSource] = .init()
    var hasPokemondSources: Bool = false
    var canLoadMore: Bool = false

    func fetchIfEmpty() -> RxSwift.Observable<[SampleList.PokemonList.PokemonSource]> {
        return .just(.init())
    }

    func refresh() -> Observable<[PokemonList.PokemonSource]> {
        return .just(.init())
    }

    func loadmore() -> Observable<[PokemonList.PokemonSource]> {
        return .just(.init())
    }
}
