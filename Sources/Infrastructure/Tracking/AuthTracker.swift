/**
 * Tracker de eventos de autenticación.
 * 
 * Esta clase proporciona funcionalidad para rastrear eventos de autenticación,
 * incluyendo intentos de login, logout, errores y métricas de rendimiento.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

public class AuthTracker {
    
    // MARK: - Properties
    
    private let logger: AuthLoggerProtocol
    private let sessionId: String
    
    // MARK: - Initialization
    
    /**
     * Inicializa el tracker de autenticación.
     * 
     * - Parameters:
     *   - logger: Logger para trazabilidad
     */
    public init(
        logger: AuthLoggerProtocol
    ) {
        self.logger = logger
        self.sessionId = UUID().uuidString
    }
    
    // MARK: - Login Events
    
    /**
     * Rastrea un intento de login.
     * 
     * - Parameters:
     *   - email: Email del usuario
     *   - source: Fuente del intento de login
     */
    public func trackLoginAttempt(email: String, source: LoginSource) {
        let event = AuthEvent.loginAttempt(
            email: email,
            source: source,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.info, "Login attempt tracked for: \(email) from \(source.description)")
    }
    
    /**
     * Rastrea un login exitoso.
     * 
     * - Parameters:
     *   - user: Usuario autenticado
     *   - loginTime: Tiempo de login
     *   - source: Fuente del login
     */
    public func trackLoginSuccess(user: User, loginTime: TimeInterval, source: LoginSource) {
        let event = AuthEvent.loginSuccess(
            userId: user.id,
            userEmail: user.email,
            loginTime: loginTime,
            source: source,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.info, "Login success tracked for user: \(user.id)")
    }
    
    /**
     * Rastrea un error de login.
     * 
     * - Parameters:
     *   - email: Email del usuario
     *   - error: Error ocurrido
     *   - source: Fuente del intento
     */
    public func trackLoginError(email: String, error: AuthError, source: LoginSource) {
        let event = AuthEvent.loginError(
            email: email,
            error: error,
            source: source,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.error, "Login error tracked for: \(email) - \(error.localizedDescription)")
    }
    
    // MARK: - Logout Events
    
    /**
     * Rastrea un logout.
     * 
     * - Parameters:
     *   - user: Usuario que se desconecta
     *   - reason: Razón del logout
     *   - sessionDuration: Duración de la sesión
     */
    public func trackLogout(user: User, reason: LogoutReason, sessionDuration: TimeInterval) {
        let event = AuthEvent.logout(
            userId: user.id,
            userEmail: user.email,
            reason: reason,
            sessionDuration: sessionDuration,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.info, "Logout tracked for user: \(user.id) - Reason: \(reason)")
    }
    
    // MARK: - Token Events
    
    /**
     * Rastrea la renovación de un token.
     * 
     * - Parameters:
     *   - userId: ID del usuario
     *   - success: Si la renovación fue exitosa
     *   - refreshTime: Tiempo de renovación
     */
    public func trackTokenRefresh(userId: String, success: Bool, refreshTime: TimeInterval) {
        let event = AuthEvent.tokenRefresh(
            userId: userId,
            success: success,
            refreshTime: refreshTime,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.debug, "Token refresh tracked for user: \(userId) - Success: \(success)")
    }
    
    /**
     * Rastrea la expiración de un token.
     * 
     * - Parameters:
     *   - userId: ID del usuario
     *   - tokenAge: Edad del token
     */
    public func trackTokenExpiration(userId: String, tokenAge: TimeInterval) {
        let event = AuthEvent.tokenExpiration(
            userId: userId,
            tokenAge: tokenAge,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.warning, "Token expiration tracked for user: \(userId)")
    }

    // MARK: - Performance Events
    
    /**
     * Rastrea el rendimiento de una operación de autenticación.
     * 
     * - Parameters:
     *   - operation: Tipo de operación
     *   - duration: Duración de la operación
     *   - success: Si la operación fue exitosa
     */
    public func trackPerformance(operation: AuthOperation, duration: TimeInterval, success: Bool) {
        let event = AuthEvent.performance(
            operation: operation,
            duration: duration,
            success: success,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.debug, "Performance tracked for \(operation.description) - \(duration)s")
    }
    
    // MARK: - Session Events
    
    /**
     * Rastrea el inicio de una sesión.
     * 
     * - Parameters:
     *   - user: Usuario de la sesión
     *   - deviceInfo: Información del dispositivo
     */
    public func trackSessionStart(user: User, deviceInfo: DeviceInfo) {
        let event = AuthEvent.sessionStart(
            userId: user.id,
            userEmail: user.email,
            deviceInfo: deviceInfo,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.info, "Session start tracked for user: \(user.id)")
    }
    
    /**
     * Rastrea el fin de una sesión.
     * 
     * - Parameters:
     *   - user: Usuario de la sesión
     *   - sessionDuration: Duración de la sesión
     *   - reason: Razón del fin de sesión
     */
    public func trackSessionEnd(user: User, sessionDuration: TimeInterval, reason: SessionEndReason) {
        let event = AuthEvent.sessionEnd(
            userId: user.id,
            userEmail: user.email,
            sessionDuration: sessionDuration,
            reason: reason,
            timestamp: Date(),
            sessionId: sessionId
        )
        
        logger.log(.info, "Session end tracked for user: \(user.id) - Duration: \(sessionDuration)s")
    }
    
}

// MARK: - AuthEvent

/**
 * Eventos de autenticación que se pueden rastrear.
 */
public enum AuthEvent {
    
    case loginAttempt(email: String, source: LoginSource, timestamp: Date, sessionId: String)
    case loginSuccess(userId: String, userEmail: String, loginTime: TimeInterval, source: LoginSource, timestamp: Date, sessionId: String)
    case loginError(email: String, error: AuthError, source: LoginSource, timestamp: Date, sessionId: String)
    case logout(userId: String, userEmail: String, reason: LogoutReason, sessionDuration: TimeInterval, timestamp: Date, sessionId: String)
    case tokenRefresh(userId: String, success: Bool, refreshTime: TimeInterval, timestamp: Date, sessionId: String)
    case tokenExpiration(userId: String, tokenAge: TimeInterval, timestamp: Date, sessionId: String)
    case failedAttempt(email: String, attemptNumber: Int, source: LoginSource, timestamp: Date, sessionId: String)
    case accountLockout(email: String, lockoutDuration: TimeInterval, attemptCount: Int, timestamp: Date, sessionId: String)
    case blockedAccess(email: String, timestamp: Date, sessionId: String)
    case performance(operation: AuthOperation, duration: TimeInterval, success: Bool, timestamp: Date, sessionId: String)
    case sessionStart(userId: String, userEmail: String, deviceInfo: DeviceInfo, timestamp: Date, sessionId: String)
    case sessionEnd(userId: String, userEmail: String, sessionDuration: TimeInterval, reason: SessionEndReason, timestamp: Date, sessionId: String)
    
    /**
     * Obtiene el nombre del evento.
     * 
     * - Returns: Nombre del evento
     */
    public var name: String {
        switch self {
        case .loginAttempt:
            return "auth_login_attempt"
        case .loginSuccess:
            return "auth_login_success"
        case .loginError:
            return "auth_login_error"
        case .logout:
            return "auth_logout"
        case .tokenRefresh:
            return "auth_token_refresh"
        case .tokenExpiration:
            return "auth_token_expiration"
        case .failedAttempt:
            return "auth_failed_attempt"
        case .accountLockout:
            return "auth_account_lockout"
        case .blockedAccess:
            return "auth_blocked_access"
        case .performance:
            return "auth_performance"
        case .sessionStart:
            return "auth_session_start"
        case .sessionEnd:
            return "auth_session_end"
        }
    }
    
}

// MARK: - Supporting Types

/**
 * Fuentes de login.
 */
public enum LoginSource: String, CaseIterable {
    
    case loginScreen = "login_screen"
    case biometric = "biometric"
    case autoLogin = "auto_login"
    case deepLink = "deep_link"
    case external = "external"
    
    public var description: String {
        switch self {
        case .loginScreen:
            return "Pantalla de login"
        case .biometric:
            return "Autenticación biométrica"
        case .autoLogin:
            return "Login automático"
        case .deepLink:
            return "Deep link"
        case .external:
            return "Fuente externa"
        }
    }
}

/**
 * Operaciones de autenticación.
 */
public enum AuthOperation: String, CaseIterable {
    
    case login = "login"
    case logout = "logout"
    case tokenRefresh = "token_refresh"
    case sessionValidation = "session_validation"
    case passwordChange = "password_change"
    case passwordReset = "password_reset"
    
    public var description: String {
        switch self {
        case .login:
            return "Login"
        case .logout:
            return "Logout"
        case .tokenRefresh:
            return "Renovación de token"
        case .sessionValidation:
            return "Validación de sesión"
        case .passwordChange:
            return "Cambio de contraseña"
        case .passwordReset:
            return "Reset de contraseña"
        }
    }
}

/**
 * Razones de fin de sesión.
 */
public enum SessionEndReason: String, CaseIterable {
    
    case userLogout = "user_logout"
    case tokenExpired = "token_expired"
    case serverError = "server_error"
    case securityViolation = "security_violation"
    case accountDeactivated = "account_deactivated"
    case sessionTimeout = "session_timeout"
    case forceLogout = "force_logout"
    
    public var description: String {
        switch self {
        case .userLogout:
            return "Logout del usuario"
        case .tokenExpired:
            return "Token expirado"
        case .serverError:
            return "Error del servidor"
        case .securityViolation:
            return "Violación de seguridad"
        case .accountDeactivated:
            return "Cuenta desactivada"
        case .sessionTimeout:
            return "Tiempo de sesión agotado"
        case .forceLogout:
            return "Logout forzado"
        }
    }
}
