//
//  WebSocketManager.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-20.
//

import Foundation
import SocketIO
import FirebaseAuth

extension Notification.Name {
    static let socketConnected = Notification.Name("socketConnected")
    static let socketAuthError = Notification.Name("socketAuthError")
}

final class WebSocketManager {
    static let shared = WebSocketManager()
    private init() {}

    // MARK: - Socket
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    // MARK: - State
    private var heartbeatTimer: Timer?
    private var userEmail: String = ""
    
    private var isAuthed = false

    // MARK: - Public API
    func connect(baseURL: String) {
        if socket?.status == .connected || socket?.status == .connecting {
            print("ℹ️ Socket already connected/connecting. Skip connect().")
            return
        }
        // 1) Ensure we have a logged-in Firebase user
        guard let user = Auth.auth().currentUser else {
            print("❌ No Firebase user. Please login first.")
            return
        }

        // 2) Fetch a fresh ID token (recommended)
        user.getIDTokenForcingRefresh(true) { [weak self] token, error in
            guard let self else { return }

            if let error = error {
                print("❌ Failed to get Firebase ID token:", error.localizedDescription)
                return
            }
            guard let token = token, !token.isEmpty else {
                print("❌ Empty Firebase ID token")
                return
            }

            // 3) Build / reuse SocketManager
            if self.manager == nil {
                guard let url = URL(string: baseURL) else {
                    print("❌ Invalid Socket base URL:", baseURL)
                    return
                }

                // IMPORTANT:
                // - baseURL should be https://xxxx.ngrok-free.app
                // - forceWebsockets(true) makes it use wss:// automatically
                let config: SocketIOClientConfiguration = [
                    .log(true),
                    .compress,
                    .reconnects(true),
                    .reconnectAttempts(-1),
                    .reconnectWait(2),
                    .forceWebsockets(true),
                    .connectParams(["token": token]),

                    // Optional: if you ever use self-signed certs (ngrok doesn't need this)
                    // .secure(true)
                ]

                self.manager = SocketManager(socketURL: url, config: config)
                self.socket = self.manager?.defaultSocket
                self.registerHandlers()
            } else {
                // Manager already exists; update token before connecting
                // Socket.IO-Client-Swift doesn’t let you mutate connectParams directly,
                // so safest is to rebuild manager when token changes.
                // For a simple portfolio app, rebuild when reconnecting:
                self.manager?.disconnect()
                self.manager = nil
                self.socket = nil
                self.connect(baseURL: baseURL)
                return
            }

            // 4) Connect
            self.socket?.connect()
        }
    }

    func disconnect() {
        stopHeartbeatTimer()
        socket?.disconnect()
    }

    // MARK: - Emitters
    func sendHeartbeat() {
        guard socket?.status == .connected, isAuthed else { return }

        socket?.emit("heartbeat")
        print("❤️ Sent heartbeat")
    }

    // Example: emit to join a room if you add that on the server
    func join(room: String) {
        socket?.emit("join", ["room": room])
    }

    // MARK: - Private
    private func registerHandlers() {
        print("register handler called")
        guard let socket = socket else { return }

        socket.on(clientEvent: .connect) { [weak self] _, _ in
            print("✅ Socket handshake connected (not authed yet)")
            self?.isAuthed = false
        }

        socket.on("auth_error") { data, _ in
            print("❌ auth_error:", data)
            NotificationCenter.default.post(name: .socketAuthError, object: data)
        }
        
        socket.onAny { event in
            print("📡 onAny event:", event.event, "items:", event.items ?? [])
        }
        
        socket.on("server_message") { data, _ in
            // Example server ACKs or logs
            print("📩 server_message:", data)
            guard let dict = data.first as? [String: Any], let msg = dict["message"] as? String
            else { return }

            if msg == "Connected" {
                self.isAuthed = true
                NotificationCenter.default.post(name: .socketConnected, object: nil)
                self.startHeartbeatTimer()
                self.sendHeartbeat()
            }
        }

        // If you relay signaling/messages from server:
        socket.on("signal") { data, _ in
            print("🔔 signal:", data)
            // parse `data` and handle in app as needed
        }

        socket.on(clientEvent: .error) { data, _ in
            print("❌ Socket error:", data)
        }

        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            print("❌ Socket disconnected:", data)
            self?.stopHeartbeatTimer()
        }

        socket.on(clientEvent: .reconnect) { _, _ in
            print("🔁 Reconnecting…")
        }
    }

    private func startHeartbeatTimer() {
        stopHeartbeatTimer()
        
        // Schedule on the main run loop explicitly
        DispatchQueue.main.async {
            self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
                print("sending heartbeat")
                self?.sendHeartbeat()
            }
            
            // Add to common run loop modes so it runs during scrolling/animations
            if let t = self.heartbeatTimer {
                RunLoop.main.add(t, forMode: .common)
            }
        }
    }

    private func stopHeartbeatTimer() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
}
