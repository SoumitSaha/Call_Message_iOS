//
//  WebSocketManager.swift
//  Call&Message
//
//  Created by Soumit Kanti Saha on 2025-09-20.
//

import Foundation
import SocketIO

final class WebSocketManager {
    static let shared = WebSocketManager()
    private init() {}

    // MARK: - Socket
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    // MARK: - State
    private var heartbeatTimer: Timer?
    private var userEmail: String = ""

    // MARK: - Public API
    func connect(email: String, baseURL: String) {
        userEmail = email

        // Reuse existing connection if already configured
        if manager == nil {
            guard let url = URL(string: baseURL) else {
                print("❌ Invalid Socket base URL:", baseURL)
                return
            }

            let config: SocketIOClientConfiguration = [
                .log(true),
                .compress,
                .reconnects(true), // auto-reconnect
                .reconnectAttempts(-1), // infinite reconnect attempts
                .reconnectWait(2), // 2 seconds wait in reach reconnect attempt
                // Force websockets as I don’t want polling:
                .forceWebsockets(true),
                .connectParams(["email": email])
            ]

            manager = SocketManager(socketURL: url, config: config)
            socket = manager?.defaultSocket
            registerHandlers()
        }

        socket?.connect()
    }

    func disconnect() {
        stopHeartbeatTimer()
        socket?.disconnect()
    }

    // MARK: - Emitters
    func sendHeartbeat() {
        guard socket?.status == .connected else { return }
        guard !userEmail.isEmpty else { return }

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
            print("✅ Socket connected")
            self?.startHeartbeatTimer()
            // Optional: immediately send first heartbeat
            self?.sendHeartbeat()
        }

        socket.on("server_message") { data, _ in
            // Example server ACKs or logs
            print("📩 server_message:", data)
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
