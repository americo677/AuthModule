//
//  AuthRepository.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 29/07/25.
//

/**
 * Implementación del repositorio de autenticación.
 * 
 * Esta clase implementa el protocolo AuthRepositoryProtocol y coordina
 * las operaciones entre el servicio de red, almacenamiento seguro y
 * gestión de intentos fallidos.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

@MainActor
public class AuthRepository: AuthRepositoryProtocol {
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceProtocol
    private let secureStorage: SecureStorageProtocol
    private let logger: AuthLoggerProtocol
    
    // MARK: - Initialization
    
    /**
     * Inicializa el repositorio de autenticación.
     * 
     * - Parameters:
     *   - networkService: Servicio de red para comunicación con el servidor
     *   - secureStorage: Almacenamiento seguro para tokens y sesiones
     *   - logger: Logger para trazabilidad
     */
    public init(
        networkService: NetworkServiceProtocol,
        secureStorage: SecureStorageProtocol,
        logger: AuthLoggerProtocol
    ) {
        self.networkService = networkService
        self.secureStorage = secureStorage
        self.logger = logger
    }
    
    // MARK: - Authentication Operations
    
    public func login(credentials: LoginCredentials) async throws -> AuthSession {
        logger.log(.info, "Iniciando login para: \(credentials.email)")
        
        do {
            // Create login request
            let loginRequest = LoginRequest(
                email: credentials.email,
                password: credentials.password
            )
            
            // Perform login request
            guard let response = try await performLoginRequest(loginRequest) else {
                throw mapError(AuthError.networkError)
            }
            
            // Create session
            let session = AuthSession(
                user: response.user,
                token: response.token,
                lastActivity: Date()
            )
            
            // Save token securely
            try secureStorage.saveToken(response.token)
            
            logger.log(.info, "Login exitoso para: \(credentials.email)")
            return session
            
        } catch {
            // Map and re-throw error
            logger.log(.error, "Error en login: \(error.localizedDescription)")
            throw mapError(error)
        }
    }
    
    public func refreshToken(refreshToken: String) async throws -> AuthToken {
        logger.log(.debug, "Renovando token")
        
        do {
            // Create refresh request
            let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
            
            // Perform refresh request
            let response = try await performRefreshRequest(refreshRequest)
            
            logger.log(.debug, "Token renovado exitosamente")
            return response.token
            
        } catch {
            logger.log(.error, "Error al renovar token: \(error.localizedDescription)")
            throw mapError(error)
        }
    }
    
    public func logout() async throws {
        logger.log(.info, "Iniciando logout")
        
        do {
            // Get current session to obtain access token
            if let session = try await getCurrentSession() {
                // Perform logout request
                try await performLogoutRequest(accessToken: session.token.accessToken)
            }
            
            // Clear local token regardless of server response
            try secureStorage.clearToken()
            
            logger.log(.info, "Logout completado")
            
        } catch {
            logger.log(.warning, "Error en logout del servidor, pero limpiando sesión local: \(error.localizedDescription)")
            // Even if server logout fails, we should clear local token
            try secureStorage.clearToken()
        }
    }
    
    // MARK: - Session Management
    
    public func getCurrentSession() async throws -> AuthSession? {
        logger.log(.info, "Obtener la sesión actual")
        guard let token = try secureStorage.getToken() else {
            return nil
        }
        return nil
    }
    

    
    public func isAuthenticated() async -> Bool {
        logger.log(.info, "Está autenticado el usuario?")
        return secureStorage.hasValidToken()
    }
    
    public func getAccessToken() async throws -> String? {
        logger.log(.info, "Obtener el token de acceso")
        guard let session = try await getCurrentSession() else {
            return nil
        }
        
        if session.token.willExpireSoon {
            do {
                let newToken = try await refreshToken(refreshToken: session.token.refreshToken)
                try secureStorage.saveToken(newToken)
                
                return newToken.accessToken
            } catch {
                try secureStorage.clearToken()
                throw AuthError.tokenExpired
            }
        }
        
        return session.token.accessToken
    }
    
    // MARK: - Token Management
    
    public func needsTokenRefresh() async -> Bool {
        guard let session = try? await getCurrentSession() else {
            return false
        }
        
        return session.token.willExpireSoon
    }
    
    public func refreshTokenIfNeeded() async throws -> Bool {
        guard await needsTokenRefresh() else {
            return false
        }
        
        guard let session = try await getCurrentSession() else {
            throw AuthError.noActiveSession
        }
        
        do {
            let newToken = try await refreshToken(refreshToken: session.token.refreshToken)
            try secureStorage.saveToken(newToken)
            return true
        } catch {
            logger.log(.error, "Error al renovar token automáticamente: \(error.localizedDescription)")
            throw error
        }
    }
    

    
    // MARK: - Private Methods
    
    /**
     * Realiza la petición de login al servidor.
     * 
     * - Parameter request: Request de login
     * - Returns: Respuesta de autenticación
     * - Throws: NetworkError si la petición falla
     */
    private func performLoginRequest(_ request: LoginRequest) async throws -> AuthResponse? {
        let url = URL(string: "\(getBaseURL())/auth/login")!
        let requestData = try JSONEncoder().encode(request)
        let response = try await networkService.post(
            url: url,
            body: requestData,
            headers: getDefaultHeaders(),
            timeout: nil
        )
        
        return nil
    }
    
    /**
     * Realiza la petición de refresh de token al servidor.
     * 
     * - Parameter request: Request de refresh
     * - Returns: Respuesta de refresh
     * - Throws: NetworkError si la petición falla
     */
    private func performRefreshRequest(_ request: RefreshTokenRequest) async throws -> RefreshTokenResponse {
        let url = URL(string: "\(getBaseURL())/auth/refresh")!
        
        let requestData = try JSONEncoder().encode(request)
        
        let response = try await networkService.post(
            url: url,
            body: requestData,
            headers: getDefaultHeaders(),
            timeout: nil
        )
        
        return try JSONDecoder().decode(RefreshTokenResponse.self, from: response.data)
    }
    
    /**
     * Realiza la petición de logout al servidor.
     * 
     * - Parameter accessToken: Token de acceso
     * - Throws: NetworkError si la petición falla
     */
    private func performLogoutRequest(accessToken: String) async throws {
        let url = URL(string: "\(getBaseURL())/auth/logout")!
        
        let headers = getDefaultHeaders().merging([
            "Authorization": "Bearer \(accessToken)"
        ]) { _, new in new }
        
        _ = try await networkService.post(
            url: url,
            body: nil,
            headers: headers,
            timeout: nil
        )
    }
    
    /**
     * Obtiene la URL base para las peticiones.
     * 
     * - Returns: URL base
     */
    private func getBaseURL() -> String {
        // Debe venir de la configuración
        return "https://api.example.com"
    }
    
    /**
     * Obtiene los headers por defecto para las peticiones.
     * 
     * - Returns: Headers por defecto
     */
    private func getDefaultHeaders() -> [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "AuthModule/1.0.0"
        ]
    }
    
    /**
     * Mapea errores específicos a AuthError.
     * 
     * - Parameter error: Error original
     * - Returns: AuthError mapeado
     */
    private func mapError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternetConnection:
                return .networkError
            case .timeout:
                return .timeout
            case .serverError(let code):
                return .serverError(code)
            case .clientError(let code) where code == 401:
                return .invalidCredentials
            case .clientError(let code) where code == 403:
                return .notAuthorized
            case .clientError(let code) where code == 404:
                return .unknown
            case .clientError(let code) where code == 429:
                return .serverError(429)
            default:
                return .networkError
            }
        }
        
        return .unknown
    }
}

 
