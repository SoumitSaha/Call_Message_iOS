//
//  DatabaseManager.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    private let db: Connection?
    
    // Table & Columns
    private let users = Table("UserInfo")
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let email = Expression<String>("email")
    private let dob = Expression<Int64>("dob")
    private let image = Expression<Data?>("image") // store image path or base64
    private let isLoggedInStatus = Expression<Bool>("isLoggedInStatus")
    
    private init() {
        // Path to Documents folder
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/users.sqlite3")
            createTable()
        } catch {
            db = nil
            print("Unable to open database: \(error)")
        }
    }
    
    private func createTable() {
        do {
            try db?.run(users.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(name)
                t.column(email, unique: true)
                t.column(dob)
                t.column(image)
                t.column(isLoggedInStatus)
            })
        } catch {
            print("Table creation failed: \(error)")
        }
    }
    
    // Insert new user
    func insertUser(name: String, email: String, dob: Date, image: Data?, isLoggedIn: Bool) {
        let dobTimestamp = Int64(dob.timeIntervalSince1970)
        do {
            let insert = users.insert(self.name <- name,
                                      self.email <- email,
                                      self.dob <- dobTimestamp,
                                      self.image <- image,
                                      self.isLoggedInStatus <- isLoggedIn)
            try db?.run(insert)
        } catch {
            print("Insert failed: \(error)")
        }
    }
    
    // Update User
    func UpdateUserByEmail(emailQuery: String, updatedName: String, updatedDob: Date, isLoggedIn: Bool) {
        let dobTimestamp = Int64(updatedDob.timeIntervalSince1970)
        let user = users.filter(email == emailQuery)
        do {
            try db?.run(user.update(dob <- dobTimestamp, isLoggedInStatus <- isLoggedIn, name <- updatedName))
        } catch {
            print("Profile Update failed: \(error)")
        }
    }
    
    // Update User Image
    func UpdateUserByEmail(emailQuery: String, updatedImage: Data?) {
        let user = users.filter(email == emailQuery)
        do {
            try db?.run(user.update(image <- updatedImage))
        } catch {
            print("Image Update failed: \(error)")
        }
    }
    
    // Fetch user by email
    func getUser(byEmail emailQuery: String) -> [String: Any]? {
        do {
            if let user = try db?.pluck(users.filter(email == emailQuery)) {
                return [
                    "id": user[id],
                    "name": user[name],
                    "email": user[email],
                    "dob": user[dob],
                    "image": user[image] as Any,
                    "isLoggedInStatus": user[isLoggedInStatus]
                ]
            }
        } catch {
            print("Select failed: \(error)")
        }
        return nil
    }
    
    // Update login status
    func updateLoginStatus(emailQuery: String, status: Bool) {
        let user = users.filter(email == emailQuery)
        do {
            try db?.run(user.update(isLoggedInStatus <- status))
        } catch {
            print("Update failed: \(error)")
        }
    }
    
    // Delete all users (for testing)
    func clearUsers() {
        do {
            try db?.run(users.delete())
        } catch {
            print("Clear failed: \(error)")
        }
    }
    
    func deleteDatabaseFile() {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let fileUrl = documentDirectory.appendingPathComponent("users.sqlite3")
            
            if fileManager.fileExists(atPath: fileUrl.path) {
                try fileManager.removeItem(at: fileUrl)
                print("✅ Database file deleted")
            } else {
                print("ℹ️ Database file not found")
            }
        } catch {
            print("❌ Failed to delete database file: \(error)")
        }
    }
}
