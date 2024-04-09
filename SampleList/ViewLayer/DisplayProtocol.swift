//
//  DisplayProtocol.swift
//  SampleList
//

import Foundation

protocol PMCellDisplayable {
    var name: String { get }
    var url: String { get }
}

// MARK: - PMCellDisplayable
extension PokemonList.PokemonSource: PMCellDisplayable {}


protocol PMInfoDisplayable {
    var nameTitle: String { get }
    var idTitle: String { get }
    var typesTitle: String { get }
    var imgurl: String { get }
}

extension PokemonInfo: PMInfoDisplayable {
    var nameTitle: String { "name: " + name }
    var idTitle: String { "id: \(id)" }
    var typesTitle: String { "type: " + types.joined(separator: ", ") }
    var imgurl: String { thumbnail }
}

extension PokemonInfo {
    var display: PMInfoDisplayable {
        return self
    }
}
