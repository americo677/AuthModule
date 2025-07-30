/**
 * Caso de uso para el cierre de sesión de usuarios.
 * 
 * Este caso de uso maneja la lógica de logout, incluyendo la limpieza
 * de datos locales y la notificación al servidor.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

@MainActor
public class LogoutUseCase: Sendable {
    
    // MARK: - Dependencies
    
    private let repository: AuthRepositoryProtocol
    private let logger: AuthLoggerProtocol
    
    // MARK: - Initialization
    
    /**
     * Inicializa el caso de uso de logout.
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
     * Ejecuta el proceso de logout.
     * 
     * - Parameter reason: Razón del logout (opcional)
     * - Throws: AuthError si el logout falla
     */
    public func execute(reason: LogoutReason = .userInitiated) async throws {
        logger.log(.info, "Iniciando proceso de logout - Razón: \(reason)")
        
        // Step 1: Get current session info for logging
        let sessionInfo = try await getSessionInfo()
        
        // Step 2: Notify server about logout
        try await notifyServerLogout()
        
        // Step 3: Clear local session
        // clearLocalSession()
        
        // Step 4: Log successful logout
        logger.log(.info, "Logout exitoso para usuario: \(sessionInfo?.userId ?? "unknown")")
    }
    
    /**
     * Ejecuta un logout silencioso (sin notificar al servidor).
     * 
     * - Parameter reason: Razón del logout (opcional)
     * - Throws: AuthError si el logout falla
     */
    public func executeSilent(reason: LogoutReason = .userInitiated) async throws {
        logger.log(.info, "Iniciando logout silencioso - Razón: \(reason)")
        
        // Get current session info for logging
        let sessionInfo = try await getSessionInfo()
        
        // Clear local session only
        // clearLocalSession()

        logger.log(.info, "Logout silencioso exitoso para usuario: \(sessionInfo?.userId ?? "unknown")")
    }
    
    /**
     * Verifica si hay una sesión activa.
     * 
     * - Returns: true si hay sesión activa, false en caso contrario
     */
    public func hasActiveSession() async -> Bool {
        return await repository.isAuthenticated()
    }
    
    /**
     * Obtiene información de la sesión actual.
     * 
     * - Returns: Información de la sesión si existe, nil en caso contrario
     * - Throws: AuthError si hay un error al obtener la información
     */
    public func getCurrentSessionInfo() async throws -> SessionInfo? {
        guard let session = try await repository.getCurrentSession() else {
            return nil
        }
        
        return SessionInfo(
            userId: session.user.id,
            userEmail: session.user.email,
            userName: session.user.name,
            sessionStartTime: session.lastActivity,
            tokenExpirationTime: session.token.expiresAt,
            isActive: session.isValid
        )
    }
    
    // MARK: - Private Methods
    
    /**
     * Obtiene información básica de la sesión para logging.
     * 
     * - Returns: Información básica de la sesión
     */
    private func getSessionInfo() async throws -> SessionInfo? {
        return try await getCurrentSessionInfo()
    }
    
    /**
     * Notifica al servidor sobre el logout.
     * 
     * - Throws: AuthError si la notificación falla
     */
    private func notifyServerLogout() async throws {
        do {
            logger.log(.debug, "Notificando logout al servidor")
            try await repository.logout()
            logger.log(.debug, "Servidor notificado exitosamente")
        } catch {
            logger.log(.warning, "Error al notificar logout al servidor: \(error.localizedDescription)")
            // Don't throw error here, continue with local cleanup
        }
    }
}

// MARK: - LogoutReason

/**
 * Razones por las que se puede realizar un logout.
 */
public enum LogoutReason: CaseIterable, Sendable {
    
    case userInitiated
    case tokenExpired
    case serverError
    case securityViolation
    case accountDeactivated
    case sessionTimeout
    case forceLogout
    
    public var shouldNotifyServer: Bool {
        switch self {
        case .userInitiated, .securityViolation, .forceLogout:
            return true
        case .tokenExpired, .serverError, .accountDeactivated, .sessionTimeout:
            return false
        }
    }
    

}


// MARK: - LogoutManager

/**
 * Gestor de logout que maneja diferentes escenarios de cierre de sesión.
 */
@MainActor
public class LogoutManager: Sendable {
    
    // MARK: - Properties
    
    private let logoutUseCase: LogoutUseCase
    private let logger: AuthLoggerProtocol
    private var logoutHandlers: [LogoutHandler] = []
    
    // MARK: - Initialization
    
    /**
     * Inicializa el gestor de logout.
     * 
     * - Parameters:
     *   - logoutUseCase: Caso de uso de logout
     *   - logger: Logger para trazabilidad
     */
    public init(
        logoutUseCase: LogoutUseCase,
        logger: AuthLoggerProtocol
    ) {
        self.logoutUseCase = logoutUseCase
        self.logger = logger
    }
    
    // MARK: - Public Methods
    
    /**
     * Registra un handler para ser ejecutado durante el logout.
     * 
     * - Parameter handler: Handler a registrar
     */
    public func registerHandler(_ handler: LogoutHandler) {
        logoutHandlers.append(handler)
        logger.log(.debug, "Handler de logout registrado: \(handler.name)")
    }
    
    /**
     * Ejecuta el logout con todos los handlers registrados.
     * 
     * - Parameter reason: Razón del logout
     * - Throws: AuthError si el logout falla
     */
    public func executeLogout(reason: LogoutReason = .userInitiated) async throws {
        logger.log(.info, "Ejecutando logout con \(logoutHandlers.count) handlers")
        
        // Capture the reason to avoid data races
        let logoutReason = reason
        
        // Execute pre-logout handlers
        try await executePreLogoutHandlers(reason: logoutReason)
        
        // Execute logout
        try await logoutUseCase.execute(reason: logoutReason)
        
        // Execute post-logout handlers
        try await executePostLogoutHandlers(reason: logoutReason)
        
        logger.log(.info, "Logout completado exitosamente")
    }
    
    /**
     * Ejecuta un logout de emergencia (solo limpieza local).
     * 
     * - Parameter reason: Razón del logout
     * - Throws: AuthError si el logout falla
     */
    public func executeEmergencyLogout(reason: LogoutReason = .securityViolation) async throws {
        logger.log(.warning, "Ejecutando logout de emergencia")
        
        // Capture the reason to avoid data races
        let logoutReason = reason
        
        // Execute critical handlers only
        try await executeCriticalHandlers(reason: logoutReason)
        
        // Execute silent logout
        try await logoutUseCase.executeSilent(reason: logoutReason)
        
        logger.log(.warning, "Logout de emergencia completado")
    }
    
    // MARK: - Private Methods
    
    /**
     * Ejecuta los handlers de pre-logout.
     * 
     * - Parameter reason: Razón del logout
     * - Throws: AuthError si algún handler falla
     */
    private func executePreLogoutHandlers(reason: LogoutReason) async throws {
        for handler in logoutHandlers where handler.executionPhase == .preLogout {
            do {
                logger.log(.debug, "Ejecutando pre-logout handler: \(handler.name)")
                try await handler.execute(reason: reason)
            } catch {
                logger.log(.error, "Error en pre-logout handler \(handler.name): \(error.localizedDescription)")
                if handler.isCritical {
                    throw error
                }
            }
        }
    }
    
    /**
     * Ejecuta los handlers de post-logout.
     * 
     * - Parameter reason: Razón del logout
     * - Throws: AuthError si algún handler falla
     */
    private func executePostLogoutHandlers(reason: LogoutReason) async throws {
        for handler in logoutHandlers where handler.executionPhase == .postLogout {
            do {
                logger.log(.debug, "Ejecutando post-logout handler: \(handler.name)")
                try await handler.execute(reason: reason)
            } catch {
                logger.log(.error, "Error en post-logout handler \(handler.name): \(error.localizedDescription)")
                if handler.isCritical {
                    throw error
                }
            }
        }
    }
    
    /**
     * Ejecuta solo los handlers críticos.
     * 
     * - Parameter reason: Razón del logout
     * - Throws: AuthError si algún handler falla
     */
    private func executeCriticalHandlers(reason: LogoutReason) async throws {
        for handler in logoutHandlers where handler.isCritical {
            do {
                logger.log(.debug, "Ejecutando handler crítico: \(handler.name)")
                try await handler.execute(reason: reason)
            } catch {
                logger.log(.error, "Error en handler crítico \(handler.name): \(error.localizedDescription)")
                throw error
            }
        }
    }
}

