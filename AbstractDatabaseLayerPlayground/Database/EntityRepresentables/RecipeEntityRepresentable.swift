//
//  RecipeEntityRepresentable.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 08/11/23.
//

import Foundation

extension Recipe: EntityRepresentable {
    static func decode(representation: EntityRepresentation, visited: inout [UUID : (any EntityRepresentable)?]) -> Self? {
        if let result = visited[representation.id] {
            return (result as? Self)
        }
        
        visited.updateValue(nil, forKey: representation.id)

        guard let name = representation.values["name"] as? String,
              let difficulty = representation.values["difficulty"] as? Int,
              let foo = representation.values["foo"] as? String,
              let tagsRepresentations = representation.toManyRelationships["tags"],
              let stepsRepresentations = representation.toManyRelationships["steps"],
              let placeholderRepresentation = representation.toOneRelationships["placeholder"],
              let placeholder = Placeholder.decode(representation: placeholderRepresentation, visited: &visited) else { return nil }
        
        let steps = stepsRepresentations.reduce([Step]()) { partialResult, innerRepresentation in
            guard let model = Step.decode(representation: innerRepresentation, visited: &visited) else { return partialResult }
            
            var result = partialResult
            result.append(model)
            
            return result
        }
        
        let tags = tagsRepresentations.reduce([Tag]()) { partialResult, innerRepresentation in
            guard let model = Tag.decode(representation: innerRepresentation, visited: &visited) else { return partialResult }
            
            var result = partialResult
            result.append(model)
            
            return result
        }
        
        let result = Self.init(id: representation.id, name: name, difficulty: difficulty, steps: steps, placeholder: placeholder, foo: foo, tags: tags)
        visited[representation.id] = result
        
        return result
    }
    
    func encode(visited: inout [UUID : EntityRepresentation]) -> EntityRepresentation {
        if let result = visited[self.id] {
            return result
        }
        
        let result = EntityRepresentation(id: self.id, entityName: "RecipeEntity", values: [:], toOneRelationships: [:], toManyRelationships: [:])
        visited[self.id] = result
  
        let values: [String : Any] = [
            "id" : self.id,
            "name" : self.name,
            "difficulty" : self.difficulty as Any,
            "foo" : self.foo
        ]
        
        let toManyRelationships: [String : [EntityRepresentation]] = [
            "steps" : self.steps.map({ $0.encode(visited: &visited) }),
            "tags" : self.tags.map({ $0.encode(visited: &visited) })
        ]
        
        let toOneRelationships: [String : EntityRepresentation] = [
            "placeholder" : self.placeholder.encode(visited: &visited)
        ]
        
        result.values = values
        result.toOneRelationships = toOneRelationships
        result.toManyRelationships = toManyRelationships
        
        return result
    }
}
