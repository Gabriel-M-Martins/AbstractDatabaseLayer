//
//  CKUtility.swift
//  AbstractDatabaseLayerPlayground
//
//  Created by Gabriel Medeiros Martins on 27/11/23.
//

import Foundation
import CloudKit

class CKUtility: ObservableObject {
    @Published public var userPermited: Bool = false
    @Published public var isOK: Bool = false
    @Published public var username: String = ""
    
    
    init() {
        getStatus()
        requestPermission()
        fetchUserID()
    }
    
    func getStatus() {
        CKContainer.default().accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isOK = true
                default:
                    self?.isOK = false
                }
            }
        }
    }
    
    func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { [weak self] status, error in
            DispatchQueue.main.async {
                if status == .granted {
                    self?.userPermited = true
                }
            }
        }
    }
    
    func fetchUserID() {
        CKContainer.default().fetchUserRecordID { [weak self] userID, error in
            guard let id = userID else { return }
            self?.discoverUser(id: id)
        }
    }
    
    func discoverUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] discoveredIdentity, error in
            guard let identity = discoveredIdentity else { return }
            guard let name = identity.nameComponents?.givenName else { return }
            
            DispatchQueue.main.async {
                self?.username = name
            }
        }
    }
}
