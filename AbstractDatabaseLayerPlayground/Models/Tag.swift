//
//  Tag.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 08/11/23.
//

import Foundation

final class Tag {
    var id: UUID
    var name: String
    
    var recipes: [Recipe]
    
    init(id: UUID = UUID(), name: String = "foo", recipes: [Recipe] = []) {
        self.id = id
        self.name = name
        self.recipes = recipes
    }
}

// Hashable insiste nessa porra ser explícita por motivo de ter uma extension da struct em outro arquivo.
extension Tag {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
}


