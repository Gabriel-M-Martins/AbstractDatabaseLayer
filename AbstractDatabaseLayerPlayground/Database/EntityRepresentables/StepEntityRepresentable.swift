//
//  StepEntityRepresentation.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 08/11/23.
//

import Foundation

extension Step : EntityRepresentable {
    static func decode(representation: EntityRepresentation, visited: inout [UUID : (any EntityRepresentable)?]) -> Self? {
        if let result = visited[representation.id] {
            return (result as? Self)
        }
        
        visited[representation.id] = nil
        
        guard let idx = representation.values["idx"] as? Int else { return nil }
        
        let result = Self.init(id: representation.id, image: representation.values["image"] as? Data, timer: representation.values["timer"] as? Int, idx: idx)
        visited[representation.id] = result
        
        return result
    }
    
    func encode(visited: inout [UUID : EntityRepresentation]) -> EntityRepresentation {
        if let result = visited[self.id] {
            return result
        }
        
        let result = EntityRepresentation(id: self.id, entityName: "StepEntity", values: [:], toOneRelationships: [:], toManyRelationships: [:])
        
        let values: [String : Any] = [
            "id" : self.id,
            "timer" : self.timer as Any,
            "image" : self.image as Any,
            "idx" : self.idx as Any
        ]
        
        let toOneRelationships: [String : EntityRepresentation] = [:]
        
        let toManyRelationships: [String : [EntityRepresentation]] = [:]
        
        result.values = values
        result.toOneRelationships = toOneRelationships
        result.toManyRelationships = toManyRelationships
        
        return result
    }
}
