
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

struct EvolutionChain: Decodable {
    enum CodingKeys: String, CodingKey {
        case evolvesTo = "evolves_to"
        case species
    }

    let evolvesTo: [EvolutionChain]
    let species: Species

    struct Species: Codable {
        let name: String
        let url: String
    }
}

struct PokemonEvolutionChain: Decodable {
    let id: Int
    let chain: EvolutionChain

    func flatMapChain() -> [EvolutionChain.Species] {
        return collectSpecies(from: chain)
    }

    private func collectSpecies(from evolutionChain: EvolutionChain) -> [EvolutionChain.Species] {
        let currentSpecies = [evolutionChain.species]
        let childSpecies = evolutionChain.evolvesTo.flatMap { collectSpecies(from: $0) }
        return currentSpecies + childSpecies
    }
}

struct FormDescription: Codable {
    struct Language: Codable {
        let name: String
        let url: String
    }

    let description: String
    let language: Language
}

struct PokemonSpecies: Codable {
    struct EvolutionChainSource: Codable {
        let url: String
    }

    enum CodingKeys: String, CodingKey {
        case evolutionChain = "evolution_chain"
        case formDescriptions = "form_descriptions"
    }

    let evolutionChain: EvolutionChainSource?
    let formDescriptions: [FormDescription]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        evolutionChain = try container.decodeIfPresent(EvolutionChainSource.self, forKey: .evolutionChain)
        formDescriptions = try container.decode([FormDescription].self, forKey: .formDescriptions)
    }

    func getPreferredFromDesctiption(preferredLanguages: [String]? = Locale.preferredLanguages) -> String {
        var descriptionsByLanguage: [String: String] = [:]
        for description in formDescriptions {
            descriptionsByLanguage[description.language.name] = description.description
        }

        if let preferredLocale = preferredLanguages?.first,
           let preferredDescription = descriptionsByLanguage[preferredLocale] {
            return preferredDescription
        }

        if let englishDescription = descriptionsByLanguage["en"] {
            return englishDescription
        }

        return ""
    }
}
