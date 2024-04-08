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

        let vm = PMListVM(useCase: fakeUseCase)
        let output = vm.transfrom(input: .init(isViewAppear: mockViewIsAppear,
                                               scrollInfo: .empty(),
                                               refresh: .empty(),
                                               switchClick: .empty(),
                                               favriateSwitch: .empty()))

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

        let vm = PMListVM(useCase: fakeUseCase)
        let output = vm.transfrom(input: .init(isViewAppear: .empty(),
                                               scrollInfo: .empty(),
                                               refresh: refresh,
                                               switchClick: .empty(),
                                               favriateSwitch: .empty()))

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
        typealias ScrollInfo = PMListVM.ScrollInfo

        let offset = scheduler.createColdObservable([
            .next(0, ScrollInfo.zero()),
            .next(1, ScrollInfo(offst: CGPoint(x: 0, y: 0), contentSize: CGSize(width: 100, height: 1000), boundSize: .init(width: 414, height: 713))),
            .next(2, ScrollInfo(offst: CGPoint(x: 0, y: 200), contentSize: CGSize(width: 100, height: 1000), boundSize: .init(width: 414, height: 713))),
            .next(3, ScrollInfo(offst: CGPoint(x: 0, y: 400), contentSize: CGSize(width: 100, height: 2000), boundSize: .init(width: 414, height: 713))),
            .next(4, ScrollInfo(offst: CGPoint(x: 0, y: 1600), contentSize: CGSize(width: 100, height: 2000), boundSize: .init(width: 414, height: 713))),
            .next(5, ScrollInfo(offst: CGPoint(x: 0, y: 1800), contentSize: CGSize(width: 100, height: 3000), boundSize: .init(width: 414, height: 713)))
        ]).asDriver(onErrorDriveWith: .empty())

        let vm = PMListVM(useCase: fakeUseCase, loadMoreOffset: 100)
        let output = vm.transfrom(input: .init(isViewAppear: .empty(),
                                               scrollInfo: offset,
                                               refresh: .empty(),
                                               switchClick: .empty(),
                                               favriateSwitch: .empty()))

        let observer = scheduler.createObserver([any PMCellDisplayable].self)
        let bag = DisposeBag()

        output.dataChanged
            .drive(observer)
            .disposed(by: bag)

        scheduler.start()
        let result = observer.events.map(\.time)
        XCTAssertEqual(result, [2, 4])
    }
    
    func testInidicator() {
        let refresh = scheduler.createColdObservable([
            .next(1, ()),
            .next(2, ())
        ]).asDriver(onErrorDriveWith: .empty())

        let vm = PMListVM(useCase: fakeUseCase)
        let output = vm.transfrom(input: .init(isViewAppear: .empty(),
                                               scrollInfo: .empty(),
                                               refresh: refresh,
                                               switchClick: .empty(),
                                               favriateSwitch: .empty()))

        let observer = scheduler.createObserver(Bool.self)
        let bag = DisposeBag()
        output.dataChanged
            .drive()
            .disposed(by: bag)
        
        output.indicator
            .drive(observer)
            .disposed(by: bag)

        scheduler.start()
        let result = observer.events.map(\.value)
        XCTAssertEqual(result, [.next(true), .next(false), .next(true), .next(false)])
    }

    func testError() {

        let refresh = scheduler.createColdObservable([
            .next(1, ()),
            .next(3, ())
        ]).asDriver(onErrorDriveWith: .empty())



        let vm = PMListVM(useCase: fakeUseCase)
        let output = vm.transfrom(input: .init(isViewAppear: .empty(),
                                               scrollInfo: .empty(),
                                               refresh: refresh,
                                               switchClick: .empty(),
                                               favriateSwitch: .empty()))
        fakeUseCase.sendError = true
        scheduler.scheduleAt(2, action: { [weak fakeUseCase] in
            fakeUseCase?.sendError = false
        })

        let observer = scheduler.createObserver(ErrorDisplay?.self)
        let bag = DisposeBag()
        
        output.dataChanged
            .drive()
            .disposed(by: bag)

        output.errorDisplay
            .drive(observer)
            .disposed(by: bag)

        scheduler.start()
        let result = observer.events.map(\.value)
        typealias ErrorDisplay = SampleList.ErrorDisplay
        XCTAssertEqual(result, [.next(ErrorDisplay()), .next(nil)])
    }
}

private class FakeListUseCase: PokemonListUseCaseProtocol {
    var pokemonSources: [SampleList.PokemonList.PokemonSource] = .init()
    var hasPokemondSources: Bool = false
    var canLoadMore: Bool = false
    var sendError: Bool = false
    func fetchIfEmpty() -> RxSwift.Observable<[SampleList.PokemonList.PokemonSource]> {
        if sendError == true {
            return .error(NSError())
        }
        return .just(.init())
    }

    func refresh() -> Observable<[PokemonList.PokemonSource]> {
        if sendError == true {
            return .error(NSError())
        }
        return .just(.init())
    }

    func loadmore() -> Observable<[PokemonList.PokemonSource]> {
        if sendError == true {
            return .error(NSError())
        }
        return .just(.init())
    }
    func toggleFavoriteMode() -> Observable<[PokemonList.PokemonSource]> { .empty() }
}
