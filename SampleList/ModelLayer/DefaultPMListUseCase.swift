import Foundation
import RxSwift

protocol PokemonListUseCaseProtocol {
    var canLoadMore: Bool { get }
    var pokemonSources: [PokemonList.PokemonSource] { get }

    func fetchIfEmpty() -> Observable<[PokemonList.PokemonSource]>
    func refresh() -> Observable<[PokemonList.PokemonSource]>
    func loadmore() -> Observable<[PokemonList.PokemonSource]>

    func toggleFavoriteMode() -> Observable<[PokemonList.PokemonSource]>
}

class DefaultPMListUseCase: PokemonListUseCaseProtocol {
    private let remoteRepo: PMRemoteRepoProtocol
    private let favortieRepo: FavoriteRepoProtocol
    private(set) var pokemonSources: [PokemonList.PokemonSource] = .init()
    private var nextUrl: String?
    private var isFavoriteMode = false

    init(remoteRepo: PMRemoteRepoProtocol = PMRemoteRepo(),
         favorieRepo: FavoriteRepoProtocol = FavoriteRepo.shared) {
        self.remoteRepo = remoteRepo
        self.favortieRepo = favorieRepo
    }

    var canLoadMore: Bool {
        return nextUrl?.isEmpty == false
    }

    func fetchIfEmpty() -> Observable<[PokemonList.PokemonSource]> {
        guard pokemonSources.isEmpty else { return .empty() }
        return refresh()
    }

    func refresh() -> Observable<[PokemonList.PokemonSource]> {
        return remoteRepo.fetchPokemonList(url: "")
            .do(onNext: { [weak self] _list in
                self?.nextUrl = _list.next
                self?.pokemonSources = _list.results
            }, onError: { [weak self] _ in
                self?.nextUrl = nil
                self?.pokemonSources.removeAll()
            })
            .withUnretained(self)
            .map({ weakSelf, _ in
                return weakSelf.pokemonSources
            })
    }

    func loadmore() -> Observable<[PokemonList.PokemonSource]> {
        guard let nextUrl, canLoadMore else { return .empty()}
        return remoteRepo.fetchPokemonList(url: nextUrl)
            .do(onNext: { [weak self] _list in
                self?.nextUrl = _list.next
                self?.pokemonSources += _list.results
            })
            .withUnretained(self)
            .map({ weakSelf, _ in
                return weakSelf.pokemonSources
            })
    }

    func toggleFavoriteMode() -> Observable<[PokemonList.PokemonSource]> {
        isFavoriteMode.toggle()
        if isFavoriteMode {
            let sourceJustName = favortieRepo.favoriteList.map({ PokemonList.PokemonSource(name: $0, url: "") })
            return .just(sourceJustName)
        }
        return .just(pokemonSources)
    }
}
