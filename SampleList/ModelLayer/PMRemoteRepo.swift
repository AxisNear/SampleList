import Foundation
import RxSwift

protocol PMRemoteRepoProtocol {
    func fetchPokemonList(url: String) -> Observable<PokemonList>
    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo>
}

class PMRemoteRepo: PMRemoteRepoProtocol {
    func fetchPokemonList(url: String) -> Observable<PokemonList> {
        return .empty()
    }

    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo> {
        return .empty()
    }
}
