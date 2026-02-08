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
        URL = "https://89cd-2607-fa49-4b46-4700-4544-5bd3-4708-c78f.ngrok-free.app"
    }
}
