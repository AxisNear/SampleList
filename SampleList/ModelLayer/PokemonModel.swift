//
//  PokemonModel.swift
//  SampleList

import Foundation

struct PokemonList {
    struct PokemonSource {
        let name: String
        let url: String
    }

    let result: [PokemonSource]

    let next: String
//    let count: Int
}

struct PokemonInfo {
    let thumbnail: String
    let name: String
    let id: Int
    let types: [String]
}
