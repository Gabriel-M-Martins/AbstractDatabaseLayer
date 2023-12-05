# AbstractDatabaseLayer

This repository tries to mock a iOS app that requires database access and manipulation without having to worry about the actual database.

---

## What the duck is this?
As a backend developer, I'm currently searching and learning a lot about the best practices and designs. Recently I was developing an iOS app with a few colleagues, we tried to create a social network and one of the essential requirements to make it happen was to have a database access service that could be transferred/changed at any moment since we hadn't chosen what database we would store the data. 

We knew we were going to use CoreData and then bridge everything to CloudKit so the users could share, like posts and everything a social network has, but we didn't want it to be locked using this frameworks as it meant a strong dependency to Apple's technologies (which isn't a problem by itself, but... *you know*). 
The essential take here is: the app's **data and logic** should be independent of which database we were using. 

## The Dependency Injection

We started with the basic idea: have a Dependency Injection system so we could change the database at any moment. To be honest, a friend of mine just sent me this snippet and said that it was perfect for what we wanted:
```swift
@propertyWrapper
struct Injected<Service> {
    
    private let type: Service.Type
    
    init(_ type: Service.Type = Service.self) {
        self.type = type
    }
    
    var wrappedValue: Service {
        Dependencies.resolve(for: Service.self)
    }
}

final class Dependencies {
    
    private static var storage: [ObjectIdentifier: Any] = [:]
    
    static func register<T>(_ object: Any, for type: T.Type) {
        guard object is T else {
            fatalError("ERROR: \(object) is not a subtype of \(T.self), or does not conform to \(type)")
        }
        
        let id = ObjectIdentifier(type)
        
        if let injectedObject = storage[id] {
            print("WARNING: \(type) already has object \(injectedObject) registered; overwritting with \(object)")
        }
        
        storage[id] = object
    }
    
    static func resolve<T>(for type: T.Type) -> T {
        let id = ObjectIdentifier(type)
        
        guard let injectedObject = storage[id] as? T else {
            fatalError("ERROR: no objects registered for \(type)")
        }
        
        return injectedObject
    }
}
```

And he was right, this is a simple and effective way to store instances and inject them whenever and wherever needed. 
First we register them in the app's delegate:
```swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Dependencies.register(CoreDataRepository<Recipe>("RecipeEntity"), for: (any Repository<Recipe>).self)
        Dependencies.register(CoreDataRepository<Step>("StepEntity"), for: (any Repository<Step>).self)
        Dependencies.register(CoreDataRepository<Placeholder>("PlaceholderEntity"), for: (any Repository<Placeholder>).self)
        Dependencies.register(CoreDataRepository<Tag>("TagEntity"), for: (any Repository<Tag>).self)
        Dependencies.register(CoreDataRepository<Cookbook>("CookbookEntity"), for: (any Repository<Cookbook>).self)
        
        return true
    }
}
```

Then we just call it where it is necessary, for example in a ViewModel: 

```swift
class PlaygroundViewModel {
    @Injected private var repo: any Repository<Recipe>
}
```

Here I ask for any repository class that is of type `Recipe` and it fetches an instance of the CoreDataRepository class I registered.
This way I can implement a class that implements the `Repository` protocol, swap the `CoreDataRepository<Recipe>` for it and then all the app is now using this other database. Don't worry, I will talk about the repositories later.

## The Bridge

I did my fair share of research and tinkered **a lot** with it, experimented with a few ideas and concepts but nothing reached our expectations. Until I had a realization: what *actually* is an entity stored in the database? It is just a object with "plain" properties and "special" properties that are the relationships. Thinking of it this way, we could say we are thinking of a "representation" of an entity. And then it snapped in place: a system of three "layers".

- The model we used in the app itself.
- The entity we needed to save in the database.
- The bridge between the two. An object that could *represent* both the model and the entity.

## The Model
In our project, we were aiming to build a cooking app and so I will as an example a model we used, this is the recipe model:

```swift
class Recipe {
    var id: UUID
    var name: String
    var desc: String?
    var difficulty: Int
    var rating: Float
    var imageData: Data?
    var duration: Int
    var completed: Bool
    var owner: String
    var steps: [Step]
    var ingredients: [Ingredient]
    var tags: [Tag]
    
    
    init(id: UUID = UUID(), name: String = "", desc: String? = nil, difficulty: Int = 1, rating: Float = 0, imageData: Data? = nil, steps: [Step] = [], ingredients: [Ingredient] = [], tags: [Tag] = [], duration: Int = 0, completed: Bool = false, owner: String = "") {
        self.id = id
        self.name = name
        self.desc = desc
        self.difficulty = difficulty
        self.rating = rating
        self.imageData = imageData
        self.duration = duration
        self.owner = owner
        
        self.steps = steps
        
        self.ingredients = ingredients
        self.ingredients.sort(by: { $0.name.lowercased() < $1.name.lowercased() } )
        
        self.tags = tags
        self.completed = completed
    }
}
```

It's just a normal class that has properties and such. Nothing interesting to see here.

## The Representation
I haven't had the time to sit and study how databases (such SQLite etc) work under the hood, but I suppose it stores data in a similar way to this:

```swift
class EntityRepresentation {
    let id: UUID
    let entityName: String
    var values: [String : Any]
    var toOneRelationships: [String : EntityRepresentation]
    var toManyRelationships: [String : [EntityRepresentation]]

    init(id: UUID, entityName: String, values: [String : Any] = [:], toOneRelationships: [String : EntityRepresentation] = [:], toManyRelationships: [String : [EntityRepresentation]] = [:]) {
        self.id = id
        self.entityName = entityName
        self.values = values
        self.toOneRelationships = toOneRelationships
        self.toManyRelationships = toManyRelationships
    }
}
````

This class is, as the name says, a representation of a database entity. It has properties and relationships that point to other entities. Obviously it lacks a lot of concepts, like foreign keys etc, but it is enough to be the foundational block of code that allows us to do two things:
- Decode any Entity to a Model.
- Encode any Model to an Entity.

Now that we have a model and a representation of an entity, we need to connect the two. Currently we are doing it "manually" for each model, but I'm already developing a better (automatic) way with macros.

## The Conversion
We start with a protocol to declare what we need:
```swift
protocol EntityRepresentable {
    static func decode(representation: EntityRepresentation, visited: inout [UUID : (any EntityRepresentable)?]) -> Self?
    func encode(visited: inout [UUID : EntityRepresentation]) -> EntityRepresentation
}
```

Every model, that we use in our app should implement a way to encode and decode itself to/from an entity representation.
The recipe model implementation looks like this (don't worry, it will be better explained after the snippets):
### Encode
```swift
func encode(visited: inout [UUID : EntityRepresentation]) -> EntityRepresentation {
	if let result = visited[self.id] {
		return result
	}
	
	let result = EntityRepresentation(id: self.id, entityName: "RecipeEntity", values: [:], toOneRelationships: [:], toManyRelationships: [:])
	visited[self.id] = result
	
	var values: [String : Any] = [
		"id" : self.id,
		"name" : self.name,
		"difficulty" : self.difficulty as Any,
		"rating" : self.rating as Any,
		"duration" : self.duration as Any,
		"completed" : self.completed as Any
	]
	
	if self.desc != nil {
		values["desc"] = self.desc!
	}
	
	if self.imageData != nil {
		values["image"] = self.imageData!
	}
	
	let toOneRelationships: [String : EntityRepresentation] = [:]
	
	let toManyRelationships: [String : [EntityRepresentation]] = [
		"steps" : self.steps.map({ $0.encode(visited: &visited) }),
		"ingredients" : self.ingredients.map({ $0.encode(visited: &visited) }),
		"tags" : self.tags.map({ $0.encode(visited: &visited) }),
	]
	
	result.values = values
	result.toOneRelationships = toOneRelationships
	result.toManyRelationships = toManyRelationships
	
	return result
}
```

When encoding it simply creates an EntityRepresentation instance and populates it with the model values and returns it.
### Decode
```swift
static func decode(representation: EntityRepresentation, visited: inout [UUID : (any EntityRepresentable)?]) -> Self? {
	if let result = visited[representation.id] {
		return (result as? Self)
	}
	
	visited.updateValue(nil, forKey: representation.id)
	
	guard let name = representation.values["name"] as? String,
		  let difficulty = representation.values["difficulty"] as? Int,
		  let duration = representation.values["duration"] as? Int,
		  let rating = representation.values["rating"] as? Float,
		  let completed = representation.values["completed"] as? Bool,
		  let stepsRepresentations = representation.toManyRelationships["steps"],
		  let tagsRepresentations = representation.toManyRelationships["tags"],
		  let ingredientsRepresentations = representation.toManyRelationships["ingredients"] else { return nil }
	
	let desc = representation.values["desc"] as? String
	let imageData = representation.values["image"] as? Data
	
	let steps = stepsRepresentations.reduce([Step]()) { partialResult, innerRepresentation in
		guard let step = Step.decode(representation: innerRepresentation, visited: &visited) else { return partialResult }
		
		var result = partialResult
		result.append(step)
		
		return result
	}
	.sorted(by: { $0.order < $1.order })
	
	let tags = tagsRepresentations.reduce([Tag]()) { partialResult, innerRepresentation in
		guard let model = Tag.decode(representation: innerRepresentation, visited: &visited) else { return partialResult }
		
		var result = partialResult
		result.append(model)
		
		return result
	}
	
	let ingredients = ingredientsRepresentations.reduce([Ingredient]()) { partialResult, innerRepresentation in
		guard let model = Ingredient.decode(representation: innerRepresentation, visited: &visited) else { return partialResult }
		
		var result = partialResult
		result.append(model)
		
		return result
	}
	
	let result = Self.init(id: representation.id, name: name, desc: desc, difficulty: difficulty, rating: rating, imageData: imageData, steps: steps, ingredients: ingredients, tags: tags, duration: duration, completed: completed)
	visited[representation.id] = result
	
	return result
}
```

As a representation can have wrong values, or miss them altogether, decoding a model that requires something without having the value stored on the representation leads to a `nil` result.

Both the encoding and the decoding implementations have two relevant/interesting things:
- They can be implemented automatically through something like macros (currently in development).
- They require a `visited` parameter to avoid infinite recursion. (Specially when decoding, circular instantiation drove me crazy at one point).

## The Database
In the beginning I showed the snippet for Dependency Injection which registered a `CoreDataRepository<Model>` for whoever needs `any Repository<Model>`. But what does this mean?
The `Repository<Model>` is a simple protocol that declares the basic methods any repository should have:
```swift
protocol Repository<Model> {
    associatedtype Model
    func fetch() -> [Model]
    func fetch(id: UUID) -> Model?
    func save(_ model: Model)
    func delete(_ model: Model)
}
```

In other words: the app's code can depended on whatever I declare as a Repository for that specific model.

Now, the `CoreDataRepository`implementation is just a wrapper around CoreData's standard functions but in a "generic" way. It uses EntityRepresentations to encode/decode CoreData's entities into useful models. The code is found [here](https://github.com/Gabriel-M-Martins/AbstractDatabaseLayer/blob/main/AbstractDatabaseLayerPlayground/Database/CoreData/CoreDataRepository.swift).

## The Conclusion
Now that we have models, representations and conversions between the two we can look at *basically any database stack* and implement the encode/decode code from the representation to the entity. We just need to implement a `Repository` class and encode/decode from the entities it actually holds. Simple as that.
