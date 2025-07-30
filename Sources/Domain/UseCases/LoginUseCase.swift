/**
 * Caso de uso para la autenticación de usuarios.
 * 
 * Este caso de uso encapsula toda la lógica de negocio relacionada con el login,
 * incluyendo validación de credenciales, manejo de intentos fallidos y gestión de sesiones.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

@MainActor
public class LoginUseCase: Sendable {
    
    // MARK: - Dependencies
    
    private let repository: AuthRepositoryProtocol
    private let validator: CredentialValidatorProtocol
    private let logger: AuthLoggerProtocol
    
    // MARK: - Initialization
    
    /**
     * Inicializa el caso de uso de login.
     * 
     * - Parameters:
     *   - repository: Repositorio de autenticación
     *   - validator: Validador de credenciales
     *   - logger: Logger para trazabilidad
     */
    public init(
        repository: AuthRepositoryProtocol,
        validator: CredentialValidatorProtocol,
        logger: AuthLoggerProtocol
    ) {
        self.repository = repository
        self.validator = validator
        self.logger = logger
    }
    
    // MARK: - Public Methods
    
    /**
     * Ejecuta el proceso de autenticación.
     * 
     * - Parameter credentials: Credenciales del usuario
     * - Returns: Sesión de autenticación exitosa
     * - Throws: AuthError si la autenticación falla
     */
    public func execute(credentials: LoginCredentials) async throws -> AuthSession {
        logger.log(.info, "Iniciando proceso de autenticación para: \(credentials.email)")
        
        // Step 1: Validate credentials format
        try await validateCredentials(credentials)
        
        // Step 2: Attempt authentication
        let session = try await performAuthentication(credentials)
        
        // Step 3: Log successful authentication
        logger.log(.info, "Autenticación exitosa para usuario: \(session.user.id)")
        
        return session
    }
    
    /**
     * Valida las credenciales sin realizar autenticación.
     * 
     * - Parameter credentials: Credenciales a validar
     * - Returns: Resultado de la validación
     */
    public func validateCredentials(_ credentials: LoginCredentials) -> ValidationResult {
        logger.log(.debug, "Validando credenciales para: \(credentials.email)")
        
        let result = validator.validateCredentials(credentials)
        
        if !result.isValid {
            logger.log(.warning, "Validación fallida: \(result.errors.map { $0.localizedDescription })")
        } else {
            logger.log(.debug, "Validación exitosa")
        }
        
        return result
    }
    
    // MARK: - Private Methods
    
    /**
     * Valida las credenciales y lanza error si no son válidas.
     * 
     * - Parameter credentials: Credenciales a validar
     * - Throws: AuthError si las credenciales no son válidas
     */
    private func validateCredentials(_ credentials: LoginCredentials) async throws {
        let validationResult = validator.validateCredentials(credentials)
        
        guard validationResult.isValid else {
            logger.log(.error, "Credenciales inválidas: \(validationResult.errors)")
            throw AuthError.validationFailed(validationResult.errors)
        }
    }
    
    /**
     * Realiza la autenticación.
     * 
     * - Parameter credentials: Credenciales del usuario
     * - Returns: Sesión de autenticación exitosa
     * - Throws: AuthError si la autenticación falla
     */
    private func performAuthentication(_ credentials: LoginCredentials) async throws -> AuthSession {
        do {
            logger.log(.debug, "Intentando autenticación con el servidor")
            return try await repository.login(credentials: credentials)
        } catch {
            // Log the error and re-throw
            logger.log(.error, "Error de autenticación: \(error.localizedDescription)")
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
        
        // Map validation errors
        if let validationError = error as? ValidationError {
            switch validationError {
            case .invalidEmail:
                return .invalidEmail
            case .invalidPassword:
                return .invalidPassword
            default:
                return .validationFailed([validationError])
            }
        }
        
        // Default to unknown error
        logger.log(.error, "Error no mapeado: \(error)")
        return .unknown
    }
}

/**
 * Niveles de logging disponibles.
 */
public enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}

