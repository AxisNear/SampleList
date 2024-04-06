//
//  PokemonListTest.swift
//  SampleListTests

import XCTest
@testable import SampleList
@testable import RxSwift
import RxTest
final class PokemonListUseCaseTest: XCTestCase {
    var scheduler: TestScheduler!
    override func setUp() {
        super.setUp()
        scheduler = .init(initialClock: 0)
    }
    func testRefresh() {
        let bag: DisposeBag = .init()
        var repo = FakeRepo()
        let useCase = PokemonListUseCase(remoteRepo: repo)
        XCTAssertEqual(useCase.canLoadMore, false)
        
        let obsever = scheduler.createObserver([PokemonList.PokemonSource].self)
        useCase.refresh()
            .subscribe(obsever)
            .disposed(by: bag)

        XCTAssertEqual(useCase.pokemonSources.count, 2)
        XCTAssertEqual(useCase.canLoadMore, true)

        // test refresh when error occur
        repo.sendError = true
        useCase.refresh()
            .subscribe(obsever)
            .disposed(by: bag)

        XCTAssertEqual(useCase.pokemonSources.count, 0)
        XCTAssertEqual(useCase.canLoadMore, false)
    }

    func testLoadmore() {
        let bag: DisposeBag = .init()
        var repo = FakeRepo()
        let useCase = PokemonListUseCase(remoteRepo: repo)
        XCTAssertEqual(useCase.canLoadMore, false)

        let obsever = scheduler.createObserver([PokemonList.PokemonSource].self)
        useCase.refresh()
            .subscribe(obsever)
            .disposed(by: bag)

        XCTAssertEqual(useCase.pokemonSources.count, 2)
        XCTAssertEqual(useCase.canLoadMore, true)

        useCase.loadmore()
            .subscribe(obsever)
            .disposed(by: bag)

        XCTAssertEqual(useCase.pokemonSources.count, 4)
        XCTAssertEqual(useCase.canLoadMore, true)

        useCase.loadmore()
            .subscribe(obsever)
            .disposed(by: bag)

        XCTAssertEqual(useCase.pokemonSources.count, 6)
        XCTAssertEqual(useCase.canLoadMore, false)

        // Test no loadmore data
        useCase.loadmore()
            .subscribe(obsever)
            .disposed(by: bag)

        XCTAssertEqual(useCase.pokemonSources.count, 6)
        XCTAssertEqual(useCase.canLoadMore, false)
    }
}

fileprivate class FakeRepo: PokemonRemoteRepoProtocol {
    var sendError: Bool = false
    func fetchPokemonList(url: String) -> Observable<PokemonList> {
        if sendError == true {
            return .error(NSError())
        }
        let data: [PokemonList.PokemonSource] = [.init(name: "", url: ""),
                        .init(name: "", url: "")
                       ]
        let isRefresh = url.isEmpty
        if isRefresh {
            return .just(PokemonList.init(result: data, next: "testNext"))
        } else if url == "testNext" {
            return .just(PokemonList.init(result: data, next: "testNext2"))
        } else {
            return .just(PokemonList.init(result: data, next: ""))
        }

    }
    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo> {
        return .empty()
    }
}



