//
//  AuthSession.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - AuthSession

/**
 * Estructura que representa una sesión de autenticación completa.
 */
public struct AuthSession: Codable, Equatable, Sendable {
    
    /// Usuario autenticado
    public let user: User
    
    /// Token de autenticación
    public let token: AuthToken
    
    /// Fecha de la última actividad
    public let lastActivity: Date
    
    public init(user: User, token: AuthToken, lastActivity: Date = Date()) {
        self.user = user
        self.token = token
        self.lastActivity = lastActivity
    }
    
    /**
     * Verifica si la sesión es válida.
     * 
     * - Returns: true si la sesión es válida, false en caso contrario
     */
    public var isValid: Bool {
        return !token.isExpired && user.canAccess
    }
    
    /**
     * Verifica si la sesión necesita renovación de token.
     * 
     * - Returns: true si necesita renovación, false en caso contrario
     */
    public var needsTokenRefresh: Bool {
        return token.willExpireSoon
    }
    
    /**
     * Crea una nueva sesión actualizando la última actividad.
     * 
     * - Returns: Nueva sesión con la actividad actualizada
     */
    public func updatingLastActivity() -> AuthSession {
        return AuthSession(
            user: user,
            token: token,
            lastActivity: Date()
        )
    }
    
    /**
     * Crea una nueva sesión con un token actualizado.
     * 
     * - Parameter newToken: Nuevo token de autenticación
     * - Returns: Nueva sesión con el token actualizado
     */
    public func updatingToken(_ newToken: AuthToken) -> AuthSession {
        return AuthSession(
            user: user,
            token: newToken,
            lastActivity: Date()
        )
    }
}
