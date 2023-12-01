//
//  Cookbook.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 24/11/23.
//

import Foundation

final class Cookbook {
    var id: UUID
    var favorites: [Recipe]
    var history: [Recipe]
    
    init(id: UUID = UUID(), favorites: [Recipe] = [], history: [Recipe] = []) {
        self.id = id
        self.favorites = favorites
        self.history = history
    }
}

extension Cookbook {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    static func == (lhs: Cookbook, rhs: Cookbook) -> Bool {
        lhs.id == rhs.id
    }
}
