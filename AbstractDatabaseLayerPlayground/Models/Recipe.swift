//
//  Recipe.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 01/11/23.
//

import Foundation

final class Recipe {
    var id: UUID
    var name: String
    var difficulty: Int
    var steps: [Step]
    var placeholder: Placeholder
    
    var tags: [Tag]
    var foo: String
    
    init(id: UUID = UUID(), name: String = "NOME", difficulty: Int = 2, steps: [Step] = [], placeholder: Placeholder = Placeholder(), foo: String = "foofoi", tags: [Tag] = []) {
        self.id = id
        self.name = name
        self.difficulty = difficulty
        self.steps = steps
        self.placeholder = placeholder
        self.foo = foo
        self.tags = tags
    }
}

// Hashable insiste nessa porra ser explícita por motivo de ter uma extension da struct em outro arquivo.
extension Recipe {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

