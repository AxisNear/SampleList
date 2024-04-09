import Foundation
import RxSwift

protocol PMRemoteRepoProtocol {
    func fetchPokemonList(url: String) -> Observable<PokemonList>
    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo>
    func fetchSpecies(name: String) -> Observable<PokemonSpecies>
    func fetchEvolutionChain(url: String) -> Observable<PokemonEvolutionChain>
}

class PMRemoteRepo: PMRemoteRepoProtocol {
    let service: PMService

    init(service: PMService = PMService()) {
        self.service = service
    }

    func fetchPokemonList(url: String) -> Observable<PokemonList> {
        let dataFetch: Observable<Data>
        if url.isEmpty {
            dataFetch = service.fetchData(api: .listPokemon)
        } else {
            dataFetch = service.fetchData(url: url)
        }
        return dataFetch
            .map({ data in
                let decoder = JSONDecoder()
                return try decoder.decode(PokemonList.self, from: data)
            })
    }

    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo> {
        guard name.isEmpty == false else { return .empty() }
        return service.fetchData(api: .info(name))
            .map({ data in
                let decoder = JSONDecoder()
                return try decoder.decode(PokemonInfo.self, from: data)
            })
    }

    func fetchSpecies(name: String) -> Observable<PokemonSpecies> {
        return service.fetchData(api: .species(name))
            .map({ data in
                let decoder = JSONDecoder()
                return try decoder.decode(PokemonSpecies.self, from: data)
            })
    }

    func fetchEvolutionChain(url: String) -> Observable<PokemonEvolutionChain> {
        return service.fetchData(url: url)
            .map({ data in
                let decoder = JSONDecoder()
                return try decoder.decode(PokemonEvolutionChain.self, from: data)
            })
    }
}
