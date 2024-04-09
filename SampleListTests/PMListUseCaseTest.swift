
@testable import RxSwift
import RxTest
@testable import SampleList
import XCTest

final class PMListUseCaseTest: XCTestCase {
    var scheduler: TestScheduler!
    override func setUp() {
        super.setUp()
        scheduler = .init(initialClock: 0)
    }

    func testFetchIfEmpty() {
        let bag: DisposeBag = .init()
        let repo = FakeRepo()
        let useCase = DefaultPMListUseCase(remoteRepo: repo)
        XCTAssertEqual(useCase.canLoadMore, false)
        let obsever = scheduler.createObserver([PokemonList.PokemonSource].self)
        useCase.fetchIfEmpty()
            .subscribe(obsever)
            .disposed(by: bag)

        XCTAssertEqual(useCase.pokemonSources.count, 2)
        XCTAssertEqual(useCase.canLoadMore, true)

        useCase.fetchIfEmpty()
            .subscribe(obsever)
            .disposed(by: bag)

        let result = obsever.events.map(\.value)
        XCTAssertEqual(result, [.next(FakeRepo.fakeData), .completed, .completed])
    }

    func testRefresh() {
        let bag: DisposeBag = .init()
        let repo = FakeRepo()
        let useCase = DefaultPMListUseCase(remoteRepo: repo)
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
        let repo = FakeRepo()
        let useCase = DefaultPMListUseCase(remoteRepo: repo)
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

private class FakeRepo: PMRemoteRepoProtocol {
    func fetchSpecies(name: String) -> RxSwift.Observable<SampleList.PokemonSpecies> {
        .empty()
    }
    
    func fetchEvolutionChain(url: String) -> RxSwift.Observable<SampleList.PokemonEvolutionChain> {
        .empty()
    }
    
    static var fakeData: [PokemonList.PokemonSource] = [.init(name: "", url: ""), .init(name: "", url: "")]
    var sendError: Bool = false
    func fetchPokemonList(url: String) -> Observable<PokemonList> {
        if sendError == true {
            return .error(NSError())
        }
        let data: [PokemonList.PokemonSource] = Self.fakeData

        let isRefresh = url.isEmpty
        if isRefresh {
            return .just(PokemonList(results: data, next: "testNext"))
        } else if url == "testNext" {
            return .just(PokemonList(results: data, next: "testNext2"))
        } else {
            return .just(PokemonList(results: data, next: ""))
        }
    }

    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo> {
        return .empty()
    }
}
