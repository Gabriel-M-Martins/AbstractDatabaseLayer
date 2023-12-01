//
//  EntityRepresentation.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 01/11/23.
//

import Foundation

/// The half-way between the structs used on the app views and business logic and the entities stored on databases.
class EntityRepresentation {
    /// Shared Id between databases to ensure data consistency.
    let id: UUID
    /// Name of the entity stored on the databases. All databases used should share the same entity names.
    /// Probably this is going to be modified in the future to be a custom struct that can specify names accordingly to the database.
    /// that is being used.
    let entityName: String
    /// The properties the entity has. Probably this is going to be modified in the future to be a custom struct that can specify properties
    /// types accordingly to the database.
    var values: [String : Any] // [String: PrimitiveValue]
    /// This should **only** map to children relationships and **never** to parent relationships as to avoid
    /// infinite mapping loops.
    var toOneRelationships: [String : EntityRepresentation]
    /// This should **only** map to children relationships and **never** to parent relationships as to avoid
    /// infinite mapping loops.
    var toManyRelationships: [String : [EntityRepresentation]]
    
    init(id: UUID, entityName: String, values: [String : Any], toOneRelationships: [String : EntityRepresentation], toManyRelationships: [String : [EntityRepresentation]]) {
        self.id = id
        self.entityName = entityName
        self.values = values
        self.toOneRelationships = toOneRelationships
        self.toManyRelationships = toManyRelationships
    }
}

/// Structs that are going to be stored in a database should implement this protocol to proper map the communication with *any* database.
protocol EntityRepresentable: Hashable {
    static func decode(representation: EntityRepresentation, visited: inout [UUID : (any EntityRepresentable)?]) -> Self?
    func encode(visited: inout [UUID : EntityRepresentation]) -> EntityRepresentation
}
