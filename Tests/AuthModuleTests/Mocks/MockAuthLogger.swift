//
//  MockAuthLogger.swift
//  AuthModuleTests
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation
@testable import AuthModule

/**
 * Mock implementation de AuthLoggerProtocol para pruebas unitarias.
 */
public class MockAuthLogger: AuthLoggerProtocol {
    
    // MARK: - Properties
    
    public var loggedMessages: [String] = []
    public var logCallCount: Int = 0
    public var lastLogLevel: LogLevel?
    public var lastLogMessage: String?
    
    // MARK: - AuthLoggerProtocol Implementation
    
    public func log(
        _ level: LogLevel,
        _ message: String,
        file: String?,
        function: String?,
        line: Int?
    ) {
        logCallCount += 1
        lastLogLevel = level
        lastLogMessage = message
        
        var formattedMessage = "[\(level.rawValue.uppercased())] \(message)"
        if let file = file, let function = function, let line = line {
            formattedMessage += " (\(file):\(line) \(function))"
        }
        loggedMessages.append(formattedMessage)
    }
    
    public func log(_ level: LogLevel, _ message: String) {
        logCallCount += 1
        lastLogLevel = level
        lastLogMessage = message
        
        let formattedMessage = "[\(level.rawValue.uppercased())] \(message)"
        loggedMessages.append(formattedMessage)
    }
    
    // MARK: - Helper Methods
    
    /**
     * Obtiene todos los mensajes loggeados.
     */
    public func getAllMessages() -> [String] {
        return loggedMessages
    }
    
    /**
     * Obtiene los mensajes loggeados con un nivel específico.
     */
    public func getMessages(for level: LogLevel) -> [String] {
        return loggedMessages.filter { $0.contains("[\(level.rawValue.uppercased())]") }
    }
    
    /**
     * Verifica si se loggeó un mensaje específico.
     */
    public func hasMessage(_ message: String) -> Bool {
        return loggedMessages.contains { $0.contains(message) }
    }
    
    /**
     * Verifica si se loggeó un mensaje con un nivel específico.
     */
    public func hasMessage(_ message: String, level: LogLevel) -> Bool {
        return loggedMessages.contains { 
            $0.contains("[\(level.rawValue.uppercased())]") && $0.contains(message)
        }
    }
    
    /**
     * Obtiene el último mensaje loggeado.
     */
    public func getLastMessage() -> String? {
        return loggedMessages.last
    }
    
    /**
     * Obtiene el último nivel de log.
     */
    public func getLastLogLevel() -> LogLevel? {
        return lastLogLevel
    }
    
    /**
     * Resetea todas las propiedades de tracking.
     */
    public func reset() {
        loggedMessages.removeAll()
        logCallCount = 0
        lastLogLevel = nil
        lastLogMessage = nil
    }
} 
