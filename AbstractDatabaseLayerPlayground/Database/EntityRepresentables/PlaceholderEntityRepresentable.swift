//
//  PlaceholderEntityRepresentable.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 08/11/23.
//

import Foundation

extension Placeholder: EntityRepresentable {
    static func decode(representation: EntityRepresentation, visited: inout [UUID : (any EntityRepresentable)?]) -> Self? {
        if let result = visited[representation.id] {
            return (result as? Self)
        }
        
        visited[representation.id] = nil
        
        guard let name = representation.values["name"] as? String else { return nil }
        
        let result = Self.init(id: representation.id, name: name)
        visited[representation.id] = result
        
        return result
    }
    
    func encode(visited: inout [UUID : EntityRepresentation]) -> EntityRepresentation {
        if let result = visited[self.id] {
            return result
        }
        
        let result = EntityRepresentation(id: self.id, entityName: "PlaceholderEntity", values: [:], toOneRelationships: [:], toManyRelationships: [:])
        
        let values: [String : Any] = [
            "id" : self.id,
            "name" : self.name
        ]
        
        let toOneRelationships: [String : EntityRepresentation] = [:]
        
        let toManyRelationships: [String : [EntityRepresentation]] = [:]
        
        result.values = values
        result.toOneRelationships = toOneRelationships
        result.toManyRelationships = toManyRelationships
        
        return result
    }
}
