//
//  Repository.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 01/11/23.
//

import Foundation


protocol Repository<Model> {
    associatedtype Model
    func fetch() -> [Model]
    func fetch(id: UUID) -> Model?
    func save(_ model: Model)
    func delete(_ model: Model)
}
