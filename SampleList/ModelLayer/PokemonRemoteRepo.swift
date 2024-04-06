//
//  PokeMonServeice.swift
//  SampleList
//
import Foundation
import RxSwift

protocol PokemonRemoteRepoProtocol {
    func fetchPokemonList(url: String) -> Observable<PokemonList>
    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo>
}

class PokemonRemoteRepo: PokemonRemoteRepoProtocol {
    func fetchPokemonList(url: String) -> Observable<PokemonList> {
        return .empty()
    }

    func fetchPokemonInfoForm(name: String) -> Observable<PokemonInfo> {
        return .empty()
    }
}
