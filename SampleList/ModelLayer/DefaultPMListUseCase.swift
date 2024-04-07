
import Foundation
import RxSwift

class DefaultPMListUseCase {
    let remoteRepo: PMRemoteRepoProtocol
    private(set) var pokemonSources: [PokemonList.PokemonSource] = .init()
    private var nextUrl: String?

    init(remoteRepo: PMRemoteRepoProtocol = PMRemoteRepo()) {
        self.remoteRepo = remoteRepo
    }

    var canLoadMore: Bool {
        return nextUrl?.isEmpty == false
    }

    func refresh() -> Observable<[PokemonList.PokemonSource]> {
        return remoteRepo.fetchPokemonList(url: "")
            .do(onNext: { [weak self] _list in
                self?.nextUrl = _list.next
                self?.pokemonSources = _list.result
            }, onError: { [weak self] _ in
                self?.nextUrl = nil
                self?.pokemonSources.removeAll()
            })
            .map({ _list in
                return _list.result
            })
    }

    func loadmore() -> Observable<[PokemonList.PokemonSource]> {
        guard let nextUrl, canLoadMore else { return .empty()}
        return remoteRepo.fetchPokemonList(url: nextUrl)
            .do(onNext: { [weak self] _list in
                self?.nextUrl = _list.next
                self?.pokemonSources += _list.result
            })
            .map({ _list in
                return _list.result
            })
    }
}
