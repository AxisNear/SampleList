//
//  PokemonModel.swift
//  SampleList

import Foundation

struct PokemonList: Decodable {
    struct PokemonSource: Equatable, Decodable {
        let name: String
        let url: String
    }

    let results: [PokemonSource]

    let next: String
//    let count: Int
}

struct PokemonInfo: Decodable {
    let thumbnail: String
    let name: String
    let id: Int
    let types: [String]

    enum CodingKeys: String, CodingKey {
        case thumbnail = "sprites"
        case name
        case id
        case types
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sprtites = try container.decode(PokemonSprite.self, forKey: .thumbnail)
        self.thumbnail = sprtites.front_default
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(Int.self, forKey: .id)
        let typesArray = try container.decode([TypeItem].self, forKey: .types)
        self.types = typesArray.map(\.type.name)
    }

    private struct PokemonSprite: Decodable {
        let front_default: String
    }

    private struct TypeItem: Decodable {
        let type: PokemonType
    }

    private struct PokemonType: Decodable {
        let name: String
        let url: String
    }
}
