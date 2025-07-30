//
//  TokenStatus.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - TokenStatus

/**
 * Estructura que representa el estado de un token de autenticación.
 */
public struct TokenStatus: Sendable {
    
    /// Indica si el token ha expirado
    public let isExpired: Bool
    
    /// Indica si el token expirará pronto
    public let willExpireSoon: Bool
    
    /// Tiempo restante hasta la expiración en segundos
    public let timeUntilExpiration: TimeInterval
    
    public init(
        isExpired: Bool,
        willExpireSoon: Bool,
        timeUntilExpiration: TimeInterval
    ) {
        self.isExpired = isExpired
        self.willExpireSoon = willExpireSoon
        self.timeUntilExpiration = timeUntilExpiration
    }
    
    /**
     * Indica si el token necesita renovación.
     *
     * - Returns: true si necesita renovación, false en caso contrario
     */
    public var needsRefresh: Bool {
        return isExpired || willExpireSoon
    }
    
    /**
     * Obtiene el tiempo restante en formato legible.
     *
     * - Returns: String con el tiempo restante
     */
    public var timeUntilExpirationFormatted: String {
        if isExpired {
            return "Expirado"
        }
        
        let minutes = Int(timeUntilExpiration / 60)
        let seconds = Int(timeUntilExpiration.truncatingRemainder(dividingBy: 60))
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

