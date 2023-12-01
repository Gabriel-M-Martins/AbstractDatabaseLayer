//
//  Placeholder.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 02/11/23.
//

import Foundation

final class Placeholder {
    var id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String = "PLACEHODLER NAME") {
        self.id = id
        self.name = name
    }
}

// Hashable insiste nessa porra ser explícita por motivo de ter uma extension da struct em outro arquivo.
extension Placeholder {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    static func == (lhs: Placeholder, rhs: Placeholder) -> Bool {
        lhs.id == rhs.id
    }
}

