//
//  Models.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - Request/Response Models

/**
 * Request de login.
 */
struct LoginRequest: Codable {
    let email: String
    let password: String
    let deviceId: String?
    let platform: String?
    
    init(email: String, password: String, deviceId: String? = nil, platform: String? = "iOS") {
        self.email = email
        self.password = password
        self.deviceId = deviceId
        self.platform = platform
    }
}

/**
 * Request de refresh de token.
 */
struct RefreshTokenRequest: Codable {
    let refreshToken: String
    let deviceId: String?
    
    init(refreshToken: String, deviceId: String? = nil) {
        self.refreshToken = refreshToken
        self.deviceId = deviceId
    }
}

/**
 * Request de cambio de contraseña.
 */
struct ChangePasswordRequest: Codable {
    let currentPassword: String
    let newPassword: String
}

/**
 * Request de reset de contraseña.
 */
struct PasswordResetRequest: Codable {
    let email: String
}

/**
 * Request de confirmación de reset de contraseña.
 */
struct PasswordResetConfirmationRequest: Codable {
    let token: String
    let newPassword: String
}

// MARK: - Response Models

/**
 * Respuesta de autenticación.
 */
struct AuthResponse: Codable {
    let user: User
    let token: AuthToken
    let message: String?
    let requiresTwoFactor: Bool?
}

/**
 * Respuesta de refresh de token.
 */
struct RefreshTokenResponse: Codable {
    let token: AuthToken
    let message: String?
}

/**
 * Respuesta de logout.
 */
struct LogoutResponse: Codable {
    let message: String
    let success: Bool
}

/**
 * Respuesta de validación de sesión.
 */
struct SessionValidationResponse: Codable {
    let isValid: Bool
    let user: User?
    let expiresAt: Date?
    let message: String?
}

/**
 * Respuesta de cambio de contraseña.
 */
struct ChangePasswordResponse: Codable {
    let success: Bool
    let message: String
    let requiresReauth: Bool?
}

/**
 * Respuesta de solicitud de reset de contraseña.
 */
struct PasswordResetResponse: Codable {
    let success: Bool
    let message: String
    let emailSent: Bool
}

/**
 * Respuesta de confirmación de reset de contraseña.
 */
struct PasswordResetConfirmationResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
}

// MARK: - APIError

/**
 * Error de la API.
 */
struct APIError: Codable {
    let code: String
    let message: String
    let details: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case code = "error_code"
        case message = "error_message"
        case details = "error_details"
    }
}
