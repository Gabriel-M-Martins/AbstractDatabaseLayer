//
//  Playground.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 01/11/23.
//

import SwiftUI
import CloudKit

class PlaygroundViewModel {
    @Injected private var _recipeRepo: any Repository<Recipe>
    @Injected private var _cookbookRepo: any Repository<Cookbook>
    
    
    var recipeRepo: any Repository<Recipe> { _recipeRepo }
    var cookbookRepo: any Repository<Cookbook> { _cookbookRepo }
    
    func addItem(name: String) {
        let newItem = CKRecord(recordType: "item")
        newItem["name"] = name
        saveItem(record: newItem)
    }
    
    func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) { _, _ in }
    }
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "item", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let record):
                print("-----------------------------qualei")
                print(record)
                print("-----------------------------")
            case .failure(let error):
                print("Error recordMatchedBlock: \(error)")
            }
        }
        
        queryOperation.queryResultBlock = { returnedResult in
            print("returned result: \(returnedResult)")
        }
        
        addOperation(operation: queryOperation)
    }
    
    func addOperation(operation: CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
}

struct Playground: View {
    @StateObject var ck: CKUtility = CKUtility()
    
    @State var viewModel: PlaygroundViewModel = PlaygroundViewModel()

    @State private var recipes: [Recipe] = []
    @State private var cookbooks: [Cookbook] = []
    @State private var count: Int = 0
    
    var body: some View {
        VStack {
            
            Text("Is OK: \(ck.isOK ? "true" : "false")")
            Text("Username: \($ck.username.wrappedValue)")
            
            Button {
                viewModel.addItem(name: "item \(count)")
                count += 1
            } label: {
                Text("aperta")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            Button {
                let recipe = Recipe(name: "receita \(recipes.count)", difficulty: recipes.count % 5, steps: [Step(timer: 10, idx: 0), Step(timer: 2, idx: 1)], placeholder: Placeholder(name: "placeholder \(recipes.count)"))
                let tags = [
                    Tag(name: "coe", recipes: [recipe]),
                    Tag(name: "bar", recipes: [recipe])
                ]
                
                recipe.tags = tags
                let cookbook = Cookbook(favorites: [recipe], history: [recipe])
                
                cookbooks.append(cookbook)
            } label: {
                Text("Criar modelo")
            }
            
            Spacer()
            Button {
                guard let lastModel = cookbooks.last else { return }
                viewModel.cookbookRepo.save(lastModel)
            } label: {
                Text("Salvar modelo no banco")
            }
            
            Spacer()
            Button {
                let fetched: [Cookbook] = viewModel.cookbookRepo.fetch()
                
                for fetch in fetched {
                    print(fetch.favorites)
                    print(fetch.history)
                    print("-------------------")
                }
                
            } label: {
                Text("Buscar modelo no banco")
            }
            
            Spacer()
            Button {
                guard let lastModel = cookbooks.last ?? viewModel.cookbookRepo.fetch().last else { return }
                cookbooks.removeAll(where: {$0.id == lastModel.id})
                viewModel.cookbookRepo.delete(lastModel)
            } label: {
                Text("Deletar modelo no banco")
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.fetchItems()
        }
    }
}

#Preview {
    Playground()
}
