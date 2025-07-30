/**
 * Caso de uso para la renovación de tokens de autenticación.
 * 
 * Este caso de uso maneja la lógica de renovación automática de tokens,
 * incluyendo la verificación de necesidad de renovación y el manejo de errores.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

@MainActor
public class RefreshTokenUseCase: Sendable {
    
    // MARK: - Dependencies
    
    private let repository: AuthRepositoryProtocol
    private let logger: AuthLoggerProtocol
    
    // MARK: - Initialization
    
    /**
     * Inicializa el caso de uso de refresh de tokens.
     * 
     * - Parameters:
     *   - repository: Repositorio de autenticación
     *   - logger: Logger para trazabilidad
     */
    public init(
        repository: AuthRepositoryProtocol,
        logger: AuthLoggerProtocol
    ) {
        self.repository = repository
        self.logger = logger
    }
    
    // MARK: - Public Methods
    
    /**
     * Ejecuta la renovación del token si es necesario.
     * 
     * - Returns: Token renovado si se realizó la renovación, nil si no era necesario
     * - Throws: AuthError si la renovación falla
     */
    public func execute() async throws -> AuthToken? {
        logger.log(.debug, "Verificando necesidad de renovación de token")
        
        // Check if token refresh is needed
        guard await repository.needsTokenRefresh() else {
            logger.log(.debug, "Renovación de token no necesaria")
            return nil
        }
        
        // Perform token refresh
        return try await performTokenRefresh()
    }
    
    /**
     * Fuerza la renovación del token independientemente de su estado.
     * 
     * - Returns: Token renovado
     * - Throws: AuthError si la renovación falla
     */
    public func forceRefresh() async throws -> AuthToken {
        logger.log(.info, "Forzando renovación de token")
        return try await performTokenRefresh()
    }
    
    /**
     * Verifica si el token actual necesita renovación.
     * 
     * - Returns: true si necesita renovación, false en caso contrario
     */
    public func needsRefresh() async -> Bool {
        return await repository.needsTokenRefresh()
    }
    
    /**
     * Obtiene información sobre el estado del token actual.
     * 
     * - Returns: Información del estado del token
     * - Throws: AuthError si no hay sesión activa
     */
    public func getTokenStatus() async throws -> TokenStatus {
        guard let session = try await repository.getCurrentSession() else {
            throw AuthError.noActiveSession
        }
        
        return TokenStatus(
            isExpired: session.token.isExpired,
            willExpireSoon: session.token.willExpireSoon,
            timeUntilExpiration: session.token.timeUntilExpiration
        )
    }
    
    // MARK: - Private Methods
    
    /**
     * Realiza la renovación del token.
     * 
     * - Returns: Token renovado
     * - Throws: AuthError si la renovación falla
     */
    private func performTokenRefresh() async throws -> AuthToken {
        logger.log(.info, "Iniciando renovación de token")
        
        do {
            // Get current session to obtain refresh token
            guard let session = try await repository.getCurrentSession() else {
                logger.log(.error, "No hay sesión activa para renovar token")
                throw AuthError.noActiveSession
            }
            
            // Check if refresh token is still valid
            guard !session.token.isExpired else {
                logger.log(.error, "Token de refresh expirado")
                throw AuthError.refreshTokenExpired
            }
            
            // Perform refresh
            let newToken = try await repository.refreshToken(refreshToken: session.token.refreshToken)
            
            // Update session with new token
            let updatedSession = session.updatingToken(newToken)
            // repository.saveSession(updatedSession)
            
            logger.log(.info, "Token renovado exitosamente")
            return newToken
            
        } catch {
            logger.log(.error, "Error al renovar token: \(error.localizedDescription)")
            
            // If refresh fails, clear the session
            // repository.clearSession()
            
            throw mapError(error)
        }
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
        
        // Map network errors
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternetConnection:
                return .networkError
            case .timeout:
                return .timeout
            case .serverError(let code):
                return .serverError(code)
            case .clientError(let code) where code == 401:
                return .refreshTokenExpired
            case .clientError(let code) where code == 403:
                return .tokenInvalid
            case .clientError(let code) where code == 404:
                return .unknown
            case .clientError(let code) where code == 429:
                return .serverError(429)
            default:
                return .networkError
            }
        }
        
        logger.log(.error, "Error no mapeado en refresh: \(error)")
        return .unknown
    }
}

