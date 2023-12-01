//
//  Step.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 02/11/23.
//

import Foundation

final class Step {
    var idx: Int
    var image: Data?
    var timer: Int?
    var id: UUID
    
    init(id: UUID = UUID(), image: Data? = nil, timer: Int? = nil, idx: Int = 0) {
        self.id = id
        self.image = image
        self.timer = timer
        self.idx = idx
    }
}

// Hashable insiste nessa porra ser explícita por motivo de ter uma extension da struct em outro arquivo.
extension Step {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
    
    static func == (lhs: Step, rhs: Step) -> Bool {
        lhs.id == rhs.id
    }
}

