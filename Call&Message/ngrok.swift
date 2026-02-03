//
//  ngrok.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-19.
//

import Foundation

class ngrok {
    static let shared = ngrok()
    public let URL: String?
    
    private init() {
        URL = "https://e103b606d20b.ngrok-free.app"
    }
}
