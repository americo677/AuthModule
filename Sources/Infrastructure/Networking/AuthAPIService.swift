/**
 * Servicio de API para operaciones de autenticación.
 * 
 * Esta clase maneja todas las peticiones HTTP específicas relacionadas con autenticación,
 * incluyendo login, logout, refresh de tokens y validación de sesiones.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

public class AuthAPIService {
    
    // MARK: - Properties
    
    private let networkService: NetworkServiceProtocol
    private let baseURL: URL
    private let logger: AuthLoggerProtocol
    
    // MARK: - Initialization
    
    /**
     * Inicializa el servicio de API de autenticación.
     * 
     * - Parameters:
     *   - networkService: Servicio de red para realizar peticiones
     *   - baseURL: URL base para las peticiones de autenticación
     *   - logger: Logger para trazabilidad
     */
    public init(
        networkService: NetworkServiceProtocol,
        baseURL: URL,
        logger: AuthLoggerProtocol
    ) {
        self.networkService = networkService
        self.baseURL = baseURL
        self.logger = logger
    }
    
    // MARK: - Authentication Endpoints
    
    /**
     * Realiza el login del usuario.
     * 
     * - Parameter credentials: Credenciales del usuario
     * - Returns: Respuesta de autenticación
     * - Throws: AuthError si el login falla
     */
    func login(credentials: LoginCredentials) async throws -> AuthResponse {
        logger.log(.info, "Realizando petición de login para: \(credentials.email)")
        
        let endpoint = AuthEndpoint.login
        let request = LoginRequest(
            email: credentials.email,
            password: credentials.password
        )
        
        return try await performRequest(
            endpoint: endpoint,
            request: request,
            responseType: AuthResponse.self
        )
    }
    
    /**
     * Renueva el token de acceso.
     * 
     * - Parameter refreshToken: Token de refresh
     * - Returns: Respuesta con el nuevo token
     * - Throws: AuthError si la renovación falla
     */
    func refreshToken(refreshToken: String) async throws -> RefreshTokenResponse {
        logger.log(.debug, "Renovando token de acceso")
        
        let endpoint = AuthEndpoint.refreshToken
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        return try await performRequest(
            endpoint: endpoint,
            request: request,
            responseType: RefreshTokenResponse.self
        )
    }
    
    /**
     * Cierra la sesión del usuario.
     * 
     * - Parameter accessToken: Token de acceso actual
     * - Throws: AuthError si el logout falla
     */
    public func logout(accessToken: String) async throws {
        logger.log(.info, "Realizando logout")
        
        let endpoint = AuthEndpoint.logout
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        _ = try await performRequest(
            endpoint: endpoint,
            headers: headers,
            responseType: LogoutResponse.self
        )
    }
    
    /**
     * Valida la sesión actual.
     * 
     * - Parameter accessToken: Token de acceso
     * - Returns: Información de la sesión
     * - Throws: AuthError si la validación falla
     */
    func validateSession(accessToken: String) async throws -> SessionValidationResponse {
        logger.log(.debug, "Validando sesión")
        
        let endpoint = AuthEndpoint.validateSession
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        return try await performRequest(
            endpoint: endpoint,
            headers: headers,
            responseType: SessionValidationResponse.self
        )
    }
    
    /**
     * Cambia la contraseña del usuario.
     * 
     * - Parameters:
     *   - currentPassword: Contraseña actual
     *   - newPassword: Nueva contraseña
     *   - accessToken: Token de acceso
     * - Returns: Respuesta del cambio de contraseña
     * - Throws: AuthError si el cambio falla
     */
    func changePassword(
        currentPassword: String,
        newPassword: String,
        accessToken: String
    ) async throws -> ChangePasswordResponse {
        logger.log(.info, "Cambiando contraseña")
        
        let endpoint = AuthEndpoint.changePassword
        let request = ChangePasswordRequest(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        return try await performRequest(
            endpoint: endpoint,
            request: request,
            headers: headers,
            responseType: ChangePasswordResponse.self
        )
    }
    
    /**
     * Solicita un reset de contraseña.
     * 
     * - Parameter email: Email del usuario
     * - Returns: Respuesta de la solicitud
     * - Throws: AuthError si la solicitud falla
     */
     func requestPasswordReset(email: String) async throws -> PasswordResetResponse {
        logger.log(.info, "Solicitando reset de contraseña para: \(email)")
        
        let endpoint = AuthEndpoint.requestPasswordReset
        let request = PasswordResetRequest(email: email)
        
        return try await performRequest(
            endpoint: endpoint,
            request: request,
            responseType: PasswordResetResponse.self
        )
    }
    
    /**
     * Confirma el reset de contraseña.
     * 
     * - Parameters:
     *   - token: Token de reset
     *   - newPassword: Nueva contraseña
     * - Returns: Respuesta de confirmación
     * - Throws: AuthError si la confirmación falla
     */
    func confirmPasswordReset(
        token: String,
        newPassword: String
    ) async throws -> PasswordResetConfirmationResponse {
        logger.log(.info, "Confirmando reset de contraseña")
        
        let endpoint = AuthEndpoint.confirmPasswordReset
        let request = PasswordResetConfirmationRequest(
            token: token,
            newPassword: newPassword
        )
        
        return try await performRequest(
            endpoint: endpoint,
            request: request,
            responseType: PasswordResetConfirmationResponse.self
        )
    }
    
    // MARK: - Private Methods
    
    /**
     * Realiza una petición genérica sin request body.
     * 
     * - Parameters:
     *   - endpoint: Endpoint de la API
     *   - headers: Headers adicionales
     *   - responseType: Tipo de respuesta esperada
     * - Returns: Respuesta decodificada
     * - Throws: AuthError si la petición falla
     */
    private func performRequest<R: Codable>(
        endpoint: AuthEndpoint,
        headers: [String: String] = [:],
        responseType: R.Type
    ) async throws -> R {
        let url = baseURL.appendingPathComponent(endpoint.path)
        
        var requestHeaders = getDefaultHeaders()
        requestHeaders.merge(headers) { _, new in new }
        
        var response: NetworkResponse? = nil
        
        switch endpoint.method {
        case .get:
            response = try await networkService.get(
                url: url,
                headers: requestHeaders,
                timeout: nil
            )
        case .post:
            response = try await networkService.post(
                url: url,
                body: nil,
                headers: requestHeaders,
                timeout: nil
            )
        case .delete:
            response = try await networkService.delete(
                url: url,
                headers: requestHeaders,
                timeout: nil
            )
        }
        
        guard let safeResponse = response else {
            throw AuthError.networkError
        }
        // Check for API errors
        try validateResponse(safeResponse)
        
        // Decode response
        do {
            let decodedResponse = try JSONDecoder().decode(R.self, from: safeResponse.data)
            logger.log(.debug, "Petición exitosa a \(endpoint.path)")
            return decodedResponse
        } catch {
            logger.log(.error, "Error decodificando respuesta: \(error.localizedDescription)")
            throw AuthError.decodingError
        }
    }
    
    /**
     * Realiza una petición genérica con request body.
     * 
     * - Parameters:
     *   - endpoint: Endpoint de la API
     *   - request: Datos de la petición
     *   - headers: Headers adicionales
     *   - responseType: Tipo de respuesta esperada
     * - Returns: Respuesta decodificada
     * - Throws: AuthError si la petición falla
     */
    private func performRequest<T: Codable, R: Codable>(
        endpoint: AuthEndpoint,
        request: T,
        headers: [String: String] = [:],
        responseType: R.Type
    ) async throws -> R {
        let url = baseURL.appendingPathComponent(endpoint.path)
        
        var requestHeaders = getDefaultHeaders()
        requestHeaders.merge(headers) { _, new in new }
        
        var response: NetworkResponse? = nil
        
        switch endpoint.method {
        case .get:
            response = try await networkService.get(
                url: url,
                headers: requestHeaders,
                timeout: nil
            )
        case .post:
            let body = try JSONEncoder().encode(request)
            response = try await networkService.post(
                url: url,
                body: body,
                headers: requestHeaders,
                timeout: nil
            )
        case .delete:
            response = try await networkService.delete(
                url: url,
                headers: requestHeaders,
                timeout: nil
            )
        }
        
        guard let safeResponse = response else {
            throw AuthError.networkError
        }
        
        // Check for API errors
        try validateResponse(safeResponse)
        
        // Decode response
        do {
            let decodedResponse = try JSONDecoder().decode(R.self, from: safeResponse.data)
            logger.log(.debug, "Petición exitosa a \(endpoint.path)")
            return decodedResponse
        } catch {
            logger.log(.error, "Error decodificando respuesta: \(error.localizedDescription)")
            throw AuthError.decodingError
        }
    }
    
    /**
     * Valida la respuesta del servidor.
     * 
     * - Parameter response: Respuesta a validar
     * - Throws: AuthError si la respuesta no es válida
     */
    private func validateResponse(_ response: NetworkResponse) throws {
        guard response.isSuccess else {
            let error = try? JSONDecoder().decode(APIError.self, from: response.data)
            throw mapAPIError(error, statusCode: response.statusCode)
        }
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
            "User-Agent": "AuthenticationModule/1.0.0",
            "X-Client-Version": "1.0.0",
            "X-Platform": "iOS"
        ]
    }
    
    /**
     * Mapea errores de API a AuthError.
     * 
     * - Parameters:
     *   - apiError: Error de la API
     *   - statusCode: Código de estado HTTP
     * - Returns: AuthError mapeado
     */
    private func mapAPIError(_ apiError: APIError?, statusCode: Int) -> AuthError {
        if let error = apiError {
            switch error.code {
            case "INVALID_CREDENTIALS":
                return .invalidCredentials
            case "TOKEN_EXPIRED":
                return .tokenExpired
            case "TOKEN_INVALID":
                return .tokenInvalid
            case "REFRESH_TOKEN_EXPIRED":
                return .refreshTokenExpired
            case "USER_INACTIVE":
                return .userInactive
            case "NOT_AUTHORIZED":
                return .notAuthorized
            default:
                return .serverError(statusCode)
            }
        }
        
        // Map HTTP status codes
        switch statusCode {
        case 400:
            return .validationFailed([])
        case 401:
            return .invalidCredentials
        case 403:
            return .notAuthorized
        case 404:
            return .unknown
        case 429:
            return .serverError(429)
        case 500...599:
            return .serverError(statusCode)
        default:
            return .unknown
        }
    }
}

// MARK: - AuthEndpoint

/**
 * Endpoints de la API de autenticación.
 */
enum AuthEndpoint {
    
    case login
    case refreshToken
    case logout
    case validateSession
    case changePassword
    case requestPasswordReset
    case confirmPasswordReset
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .refreshToken:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
        case .validateSession:
            return "/auth/validate"
        case .changePassword:
            return "/auth/change-password"
        case .requestPasswordReset:
            return "/auth/reset-password"
        case .confirmPasswordReset:
            return "/auth/reset-password/confirm"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .refreshToken, .requestPasswordReset, .confirmPasswordReset, .changePassword:
            return .post
        case .logout, .validateSession:
            return .get
        }
    }
}
