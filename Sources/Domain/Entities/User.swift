//
//  User.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 28/07/25.
//

/**
 * Entidad User que representa un usuario autenticado en el sistema.
 * 
 * Esta entidad es parte del dominio y no depende de frameworks externos.
 * Contiene la información básica del usuario después de una autenticación exitosa.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

public struct User: Codable, Equatable, Sendable {
    
    // MARK: - Properties
    
    /// Identificador único del usuario
    public let id: String
    
    /// Email del usuario (usado para autenticación)
    public let email: String
    
    /// Nombre completo del usuario
    public let name: String
    
    /// Indica si la cuenta del usuario está activa
    public let isActive: Bool
    
    /// Fecha de creación de la cuenta
    public let createdAt: Date
    
    /// Fecha de la última actividad del usuario
    public let lastActivity: Date?
    
    // MARK: - Initialization
    
    /**
     * Inicializa una nueva instancia de User.
     * 
     * - Parameters:
     *   - id: Identificador único del usuario
     *   - email: Email del usuario
     *   - name: Nombre completo del usuario
     *   - isActive: Estado de activación de la cuenta
     *   - createdAt: Fecha de creación de la cuenta
     *   - lastActivity: Fecha de la última actividad (opcional)
     */
    public init(
        id: String,
        email: String,
        name: String,
        isActive: Bool,
        createdAt: Date,
        lastActivity: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.isActive = isActive
        self.createdAt = createdAt
        self.lastActivity = lastActivity
    }
    
    // MARK: - Computed Properties
    
    /**
     * Indica si el usuario está actualmente activo y puede usar el sistema.
     * 
     * - Returns: `true` si el usuario está activo, `false` en caso contrario
     */
    public var canAccess: Bool {
        return isActive
    }
    
    /**
     * Obtiene el dominio del email del usuario.
     * 
     * - Returns: El dominio del email o "unknown" si no se puede extraer
     */
    public var emailDomain: String {
        let components = email.components(separatedBy: "@")
        return components.count > 1 ? components[1] : "unknown"
    }
    
    /**
     * Calcula la edad de la cuenta en días.
     * 
     * - Returns: El número de días desde la creación de la cuenta
     */
    public var accountAgeInDays: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: createdAt, to: now)
        return components.day ?? 0
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case isActive
        case createdAt
        case lastActivity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        
        // Handle date decoding with flexible format
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = ISO8601DateFormatter().date(from: createdAtString) ?? Date()
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        // Handle optional lastActivity
        if let lastActivityString = try? container.decodeIfPresent(String.self, forKey: .lastActivity) {
            lastActivity = ISO8601DateFormatter().date(from: lastActivityString)
        } else {
            lastActivity = try container.decodeIfPresent(Date.self, forKey: .lastActivity)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(lastActivity, forKey: .lastActivity)
    }
    
    // MARK: - Equatable Implementation
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.name == rhs.name &&
               lhs.isActive == rhs.isActive &&
               lhs.createdAt == rhs.createdAt &&
               lhs.lastActivity == rhs.lastActivity
    }
}

// MARK: - User Extensions

extension User {
    
    /**
     * Crea una copia del usuario actualizando la fecha de última actividad.
     * 
     * - Returns: Una nueva instancia de User con la última actividad actualizada
     */
    public func updatingLastActivity() -> User {
        return User(
            id: id,
            email: email,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            lastActivity: Date()
        )
    }
    
    /**
     * Crea una copia del usuario con un estado de activación diferente.
     * 
     * - Parameter isActive: El nuevo estado de activación
     * - Returns: Una nueva instancia de User con el estado actualizado
     */
    public func updatingActiveStatus(_ isActive: Bool) -> User {
        return User(
            id: id,
            email: email,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            lastActivity: lastActivity
        )
    }
} 
