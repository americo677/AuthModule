//
//  SessionInfo.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - SessionInfo

/**
 * Información de la sesión actual.
 */
public struct SessionInfo: Sendable {
    
    /// ID del usuario
    public let userId: String
    
    /// Email del usuario
    public let userEmail: String
    
    /// Nombre del usuario
    public let userName: String
    
    /// Fecha de inicio de la sesión
    public let sessionStartTime: Date
    
    /// Fecha de expiración del token
    public let tokenExpirationTime: Date
    
    /// Indica si la sesión está activa
    public let isActive: Bool
    
    public init(
        userId: String,
        userEmail: String,
        userName: String,
        sessionStartTime: Date,
        tokenExpirationTime: Date,
        isActive: Bool
    ) {
        self.userId = userId
        self.userEmail = userEmail
        self.userName = userName
        self.sessionStartTime = sessionStartTime
        self.tokenExpirationTime = tokenExpirationTime
        self.isActive = isActive
    }
    
    /**
     * Calcula la duración de la sesión en segundos.
     *
     * - Returns: Duración de la sesión en segundos
     */
    public var sessionDuration: TimeInterval {
        return Date().timeIntervalSince(sessionStartTime)
    }
    
    /**
     * Calcula el tiempo restante del token en segundos.
     *
     * - Returns: Tiempo restante en segundos, negativo si ya expiró
     */
    public var tokenTimeRemaining: TimeInterval {
        return tokenExpirationTime.timeIntervalSince(Date())
    }
}
