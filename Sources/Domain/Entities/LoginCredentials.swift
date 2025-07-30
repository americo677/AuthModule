//
//  LoginCredentials.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 28/07/25.
//

/**
 * Entidad LoginCredentials que representa las credenciales de autenticación.
 * 
 * Esta entidad encapsula los datos necesarios para autenticar un usuario,
 * incluyendo validación y sanitización de inputs.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import CommonCrypto
import Foundation

public struct LoginCredentials: Codable, Equatable, Sendable {
    
    // MARK: - Properties
    
    /// Email del usuario
    public let email: String
    
    /// Contraseña del usuario
    public let password: String
    
    /// Timestamp de creación de las credenciales
    public let createdAt: Date
    
    // MARK: - Initialization
    
    /**
     * Inicializa una nueva instancia de LoginCredentials.
     * 
     * - Parameters:
     *   - email: Email del usuario
     *   - password: Contraseña del usuario
     *   - createdAt: Fecha de creación (default: fecha actual)
     */
    public init(
        email: String,
        password: String,
        createdAt: Date = Date()
    ) {
        self.email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.password = password
        self.createdAt = createdAt
    }
    
    // MARK: - Computed Properties
    
    /**
     * Obtiene el dominio del email.
     * 
     * - Returns: El dominio del email o "unknown" si no se puede extraer
     */
    public var emailDomain: String {
        let components = email.components(separatedBy: "@")
        return components.count > 1 ? components[1] : "unknown"
    }
    
    /**
     * Indica si las credenciales están vacías.
     * 
     * - Returns: `true` si email o contraseña están vacíos, `false` en caso contrario
     */
    public var isEmpty: Bool {
        return email.isEmpty || password.isEmpty
    }
    
    /**
     * Indica si las credenciales son válidas en formato básico.
     * 
     * - Returns: `true` si el formato es válido, `false` en caso contrario
     */
    public var hasValidFormat: Bool {
        return !isEmpty && email.contains("@") && password.count >= 1
    }
    
    /**
     * Obtiene un hash seguro de las credenciales para logging (sin exponer datos sensibles).
     * 
     * - Returns: Hash seguro de las credenciales
     */
    public var secureHash: String {
        let combined = "\(email):\(password)"
        return combined.sha256().prefix(16).description
    }
    
    // MARK: - Validation Methods
    
    /**
     * Valida el formato del email.
     * 
     * - Returns: `true` si el email tiene formato válido, `false` en caso contrario
     */
    public func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /**
     * Valida la fortaleza de la contraseña.
     * 
     * - Returns: `true` si la contraseña cumple los requisitos mínimos, `false` en caso contrario
     */
    public func isValidPassword() -> Bool {
        // Mínimo 8 caracteres, al menos una letra y un número
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    /**
     * Valida que las credenciales cumplan todos los requisitos.
     * 
     * - Returns: Resultado de validación con errores específicos
     */
    public func validate() -> ValidationResult {
        var errors: [ValidationError] = []
        
        if email.isEmpty {
            errors.append(.emptyEmail)
        } else if !isValidEmail() {
            errors.append(.invalidEmail)
        }
        
        if password.isEmpty {
            errors.append(.emptyPassword)
        } else if !isValidPassword() {
            errors.append(.invalidPassword)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors
        )
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case email
        case password
        case createdAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = ISO8601DateFormatter().date(from: createdAtString) ?? Date()
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    // MARK: - Equatable Implementation
    
    public static func == (lhs: LoginCredentials, rhs: LoginCredentials) -> Bool {
        return lhs.email == rhs.email &&
               lhs.password == rhs.password &&
               lhs.createdAt == rhs.createdAt
    }
}

// MARK: - LoginCredentials Extensions

extension LoginCredentials {
    
    /**
     * Crea una copia de las credenciales con un email actualizado.
     * 
     * - Parameter newEmail: Nuevo email
     * - Returns: Una nueva instancia de LoginCredentials con el email actualizado
     */
    public func updatingEmail(_ newEmail: String) -> LoginCredentials {
        return LoginCredentials(
            email: newEmail,
            password: password,
            createdAt: createdAt
        )
    }
    
    /**
     * Crea una copia de las credenciales con una contraseña actualizada.
     * 
     * - Parameter newPassword: Nueva contraseña
     * - Returns: Una nueva instancia de LoginCredentials con la contraseña actualizada
     */
    public func updatingPassword(_ newPassword: String) -> LoginCredentials {
        return LoginCredentials(
            email: email,
            password: newPassword,
            createdAt: createdAt
        )
    }
    
    /**
     * Obtiene una representación segura para logging (sin exponer la contraseña).
     * 
     * - Returns: String seguro para logging
     */
    public var safeDescription: String {
        return "LoginCredentials(email: \(email), password: [HIDDEN], createdAt: \(createdAt))"
    }
}

// MARK: - ValidationResult

/**
 * Resultado de validación de credenciales.
 */
public struct ValidationResult {
    
    /// Indica si la validación fue exitosa
    public let isValid: Bool
    
    /// Lista de errores de validación encontrados
    public let errors: [ValidationError]
    
    public init(isValid: Bool, errors: [ValidationError] = []) {
        self.isValid = isValid
        self.errors = errors
    }
}

// MARK: - ValidationError

/**
 * Errores específicos de validación de credenciales.
 */
public enum ValidationError: LocalizedError, Equatable {
    
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case invalidPassword
    
    public var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "El email es requerido"
        case .invalidEmail:
            return "El formato del email no es válido"
        case .emptyPassword:
            return "La contraseña es requerida"
        case .invalidPassword:
            return "La contraseña debe tener al menos 8 caracteres, una letra y un número"
        }
    }
} 
