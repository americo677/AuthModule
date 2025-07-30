//
//  AuthRepositoryProtocol.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 29/07/25.
//

/**
 * Protocolo que define las operaciones del repositorio de autenticación.
 * 
 * Este protocolo encapsula toda la lógica de acceso a datos de autenticación,
 * incluyendo operaciones de login, logout, refresh de tokens y gestión de sesiones.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

@MainActor
public protocol AuthRepositoryProtocol {
    
    // MARK: - Authentication Operations
    
    /**
     * Realiza la autenticación del usuario con las credenciales proporcionadas.
     * 
     * - Parameter credentials: Credenciales de login (email y contraseña)
     * - Returns: Sesión de autenticación exitosa
     * - Throws: AuthError si la autenticación falla
     */
    func login(credentials: LoginCredentials) async throws -> AuthSession
    
    /**
     * Renueva el token de acceso usando el refresh token.
     * 
     * - Parameter refreshToken: Token de refresh válido
     * - Returns: Nuevo token de autenticación
     * - Throws: AuthError si la renovación falla
     */
    func refreshToken(refreshToken: String) async throws -> AuthToken
    
    /**
     * Cierra la sesión del usuario actual.
     * 
     * - Throws: AuthError si el logout falla
     */
    func logout() async throws
    
    // MARK: - Session Management
    
    /**
     * Obtiene la sesión actual del usuario.
     * 
     * - Returns: Sesión actual si existe y es válida, nil en caso contrario
     * - Throws: AuthError si hay un error al obtener la sesión
     */
    func getCurrentSession() async throws -> AuthSession?
    

    
    /**
     * Verifica si el usuario está actualmente autenticado.
     * 
     * - Returns: true si el usuario está autenticado, false en caso contrario
     */
    func isAuthenticated() async -> Bool
    
    /**
     * Obtiene el token de acceso actual.
     * 
     * - Returns: Token de acceso si existe y es válido, nil en caso contrario
     * - Throws: AuthError si hay un error al obtener el token
     */
    func getAccessToken() async throws -> String?
    
    // MARK: - Token Management
    
    /**
     * Verifica si el token actual necesita renovación.
     * 
     * - Returns: true si el token necesita renovación, false en caso contrario
     */
    func needsTokenRefresh() async -> Bool
    
    /**
     * Renueva automáticamente el token si es necesario.
     * 
     * - Returns: true si se renovó el token, false si no era necesario
     * - Throws: AuthError si la renovación falla
     */
    func refreshTokenIfNeeded() async throws -> Bool
}

// MARK: - AuthError

/**
 * Errores específicos de autenticación.
 */
public enum AuthError: LocalizedError, Equatable, Sendable {
    
    // Network Errors
    case networkError
    case serverError(Int)
    case timeout
    case noInternetConnection
    
    // Authentication Errors
    case invalidCredentials
    case tokenExpired
    case tokenInvalid
    case refreshTokenExpired
    case notAuthorized

    // Validation Errors
    case validationFailed([ValidationError])
    case invalidEmail
    case invalidPassword
    
    // Storage Errors
    case storageError
    case encryptionError
    case decryptionError
    
    // Session Errors
    case noActiveSession
    case sessionExpired
    case userInactive
    
    // General Errors
    case unknown
    case configurationError
    case decodingError

} 
