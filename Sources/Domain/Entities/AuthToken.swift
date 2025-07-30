//
//  AuthToken.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 28/07/25.
//

/**
 * Entidad AuthToken que representa un token de autenticación JWT.
 * 
 * Esta entidad maneja la información del token de acceso y refresh,
 * incluyendo su vigencia y validación temporal.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

public struct AuthToken: Codable, Equatable, Sendable {
    
    // MARK: - Properties
    
    /// Token de acceso JWT
    public let accessToken: String
    
    /// Token de refresh para renovar el access token
    public let refreshToken: String
    
    /// Fecha de expiración del access token
    public let expiresAt: Date
    
    /// Tipo de token (ej: "Bearer")
    public let tokenType: String
    
    /// Fecha de emisión del token
    public let issuedAt: Date
    
    // MARK: - Initialization
    
    /**
     * Inicializa una nueva instancia de AuthToken.
     * 
     * - Parameters:
     *   - accessToken: Token de acceso JWT
     *   - refreshToken: Token de refresh
     *   - expiresAt: Fecha de expiración
     *   - tokenType: Tipo de token (default: "Bearer")
     *   - issuedAt: Fecha de emisión (default: fecha actual)
     */
    public init(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date,
        tokenType: String = "Bearer",
        issuedAt: Date = Date()
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.tokenType = tokenType
        self.issuedAt = issuedAt
    }
    
    /**
     * Inicializa un AuthToken con tiempo de expiración en segundos.
     * 
     * - Parameters:
     *   - accessToken: Token de acceso JWT
     *   - refreshToken: Token de refresh
     *   - expiresIn: Tiempo de expiración en segundos
     *   - tokenType: Tipo de token (default: "Bearer")
     */
    public init(
        accessToken: String,
        refreshToken: String,
        expiresIn: TimeInterval,
        tokenType: String = "Bearer"
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = Date().addingTimeInterval(expiresIn)
        self.tokenType = tokenType
        self.issuedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /**
     * Indica si el token ha expirado.
     * 
     * - Returns: `true` si el token ha expirado, `false` en caso contrario
     */
    public var isExpired: Bool {
        return Date() >= expiresAt
    }
    
    /**
     * Indica si el token expirará pronto (en los próximos 5 minutos).
     * 
     * - Returns: `true` si el token expirará pronto, `false` en caso contrario
     */
    public var willExpireSoon: Bool {
        let fiveMinutesFromNow = Date().addingTimeInterval(5 * 60)
        return expiresAt <= fiveMinutesFromNow
    }
    
    /**
     * Calcula el tiempo restante hasta la expiración en segundos.
     * 
     * - Returns: Tiempo restante en segundos, negativo si ya expiró
     */
    public var timeUntilExpiration: TimeInterval {
        return expiresAt.timeIntervalSince(Date())
    }
    
    /**
     * Calcula el tiempo transcurrido desde la emisión en segundos.
     * 
     * - Returns: Tiempo transcurrido en segundos
     */
    public var timeSinceIssued: TimeInterval {
        return Date().timeIntervalSince(issuedAt)
    }
    
    /**
     * Obtiene el token completo con el tipo (ej: "Bearer <token>").
     * 
     * - Returns: Token completo para usar en headers de autorización
     */
    public var fullToken: String {
        return "\(tokenType) \(accessToken)"
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case tokenType = "token_type"
        case issuedAt = "issued_at"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        
        // Handle flexible date decoding
        if let expiresAtString = try? container.decode(String.self, forKey: .expiresAt) {
            expiresAt = ISO8601DateFormatter().date(from: expiresAtString) ?? Date()
        } else {
            expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        }
        
        if let issuedAtString = try? container.decode(String.self, forKey: .issuedAt) {
            issuedAt = ISO8601DateFormatter().date(from: issuedAtString) ?? Date()
        } else {
            issuedAt = try container.decode(Date.self, forKey: .issuedAt)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encode(tokenType, forKey: .tokenType)
        try container.encode(issuedAt, forKey: .issuedAt)
    }
    
    // MARK: - Equatable Implementation
    
    public static func == (lhs: AuthToken, rhs: AuthToken) -> Bool {
        return lhs.accessToken == rhs.accessToken &&
               lhs.refreshToken == rhs.refreshToken &&
               lhs.expiresAt == rhs.expiresAt &&
               lhs.tokenType == rhs.tokenType &&
               lhs.issuedAt == rhs.issuedAt
    }
}

// MARK: - AuthToken Extensions

extension AuthToken {
    
    /**
     * Crea una copia del token con una nueva fecha de expiración.
     * 
     * - Parameter newExpiresAt: Nueva fecha de expiración
     * - Returns: Una nueva instancia de AuthToken con la fecha actualizada
     */
    public func updatingExpiration(_ newExpiresAt: Date) -> AuthToken {
        return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: newExpiresAt,
            tokenType: tokenType,
            issuedAt: issuedAt
        )
    }
    
    /**
     * Crea una copia del token con un nuevo access token.
     * 
     * - Parameter newAccessToken: Nuevo token de acceso
     * - Returns: Una nueva instancia de AuthToken con el token actualizado
     */
    public func updatingAccessToken(_ newAccessToken: String) -> AuthToken {
        return AuthToken(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt,
            tokenType: tokenType,
            issuedAt: issuedAt
        )
    }
    
    /**
     * Crea una copia del token con un nuevo refresh token.
     * 
     * - Parameter newRefreshToken: Nuevo token de refresh
     * - Returns: Una nueva instancia de AuthToken con el refresh token actualizado
     */
    public func updatingRefreshToken(_ newRefreshToken: String) -> AuthToken {
        return AuthToken(
            accessToken: accessToken,
            refreshToken: newRefreshToken,
            expiresAt: expiresAt,
            tokenType: tokenType,
            issuedAt: issuedAt
        )
    }
    
    /**
     * Verifica si el token es válido para una fecha específica.
     * 
     * - Parameter date: Fecha para verificar la validez
     * - Returns: `true` si el token es válido en esa fecha, `false` en caso contrario
     */
    public func isValid(at date: Date) -> Bool {
        return date < expiresAt
    }
    
    /**
     * Calcula cuántos minutos faltan para que el token expire.
     * 
     * - Returns: Minutos restantes hasta la expiración
     */
    public var minutesUntilExpiration: Int {
        let seconds = timeUntilExpiration
        return max(0, Int(seconds / 60))
    }
} 
