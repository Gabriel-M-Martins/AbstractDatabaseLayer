//
//  TagEntityRepresentable.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 08/11/23.
//

import Foundation

extension Tag : EntityRepresentable {
    static func decode(representation: EntityRepresentation, visited: inout [UUID : (any EntityRepresentable)?]) -> Self? {
        if let result = visited[representation.id] {
            return (result as? Self)
        }
        
        visited[representation.id] = nil
        
        guard let name = representation.values["name"] as? String,
              let recipesRepresentations = representation.toManyRelationships["recipes"] else { return nil }
        
        let recipes = recipesRepresentations.reduce([Recipe]()) { partialResult, innerRepresentation in
            guard let model = Recipe.decode(representation: innerRepresentation, visited: &visited) else { return partialResult }
            
            var result = partialResult
            result.append(model)
            
            return result
        }
        
        let result = Self.init(id: representation.id, name: name, recipes: recipes)
        visited[representation.id] = result
        
        return result
    }
    
    func encode(visited: inout [UUID : EntityRepresentation]) -> EntityRepresentation {
        if let result = visited[self.id] {
            return result
        }
        
        let result = EntityRepresentation(id: self.id, entityName: "TagEntity", values: [:], toOneRelationships: [:], toManyRelationships: [:])
        
        let values: [String : Any] = [
            "id" : self.id,
            "name" : self.name
        ]

        let toOneRelationships: [String : EntityRepresentation] = [:]
        
        let toManyRelationships: [String : [EntityRepresentation]] = [
            "recipes" : self.recipes.map({ $0.encode(visited: &visited) })
        ]
        
        result.values = values
        result.toOneRelationships = toOneRelationships
        result.toManyRelationships = toManyRelationships
        
        return result
    }
    
    
}
