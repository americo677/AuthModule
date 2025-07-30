//
//  AuthenticationModule.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 29/07/25.
//

/**
 * Módulo principal de autenticación.
 * 
 * Esta clase actúa como punto de entrada principal para el módulo de autenticación,
 * proporcionando una interfaz simplificada para configurar y usar todos los servicios
 * de autenticación de manera coordinada.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

@MainActor
public class AuthenticationModule {
    
    // MARK: - Properties
    
    private let configuration: AuthenticationConfiguration
    private let loginUseCase: LoginUseCase
    private let refreshTokenUseCase: RefreshTokenUseCase
    private let logoutUseCase: LogoutUseCase
    private let repository: AuthRepository
    private let tracker: AuthTracker
    private let logger: AuthLoggerProtocol
    private let autoRefreshManager: AutoRefreshManager
    
    // MARK: - Initialization
    
    /**
     * Inicializa el módulo de autenticación.
     * 
     * - Parameter configuration: Configuración del módulo
     */
    @MainActor
    public init(configuration: AuthenticationConfiguration) throws {
        self.configuration = configuration
        
        // Initialize logger
        self.logger = DefaultAuthLogger(
            enableConsoleLogging: configuration.enableConsoleLogging,
            enableFileLogging: configuration.enableFileLogging,
            logFilePath: configuration.logFilePath
        )
        
        // Initialize network service
        let networkService = NetworkServiceFactory.createURLSessionService(
            configuration: NetworkConfiguration(
                baseURL: configuration.apiBaseURL,
                defaultTimeout: configuration.networkTimeout,
                defaultHeaders: configuration.defaultHeaders,
                sslConfiguration: configuration.sslConfiguration
            )
        )
        
        // Initialize secure storage
        let secureStorage = try KeychainManager(
            configuration: StorageConfiguration(
                serviceIdentifier: configuration.keychainServiceIdentifier,
                accessGroup: configuration.keychainAccessGroup,
                securityLevel: configuration.securityLevel,
                encryptionAlgorithm: configuration.encryptionAlgorithm,
                keySize: configuration.encryptionKeySize
            )
        )
        
        // Initialize repository
        self.repository = AuthRepository(
            networkService: networkService,
            secureStorage: secureStorage,
            logger: logger
        )

        // Initialize validator
        let validator = configuration.useEnhancedValidation ?
            EnhancedCredentialValidator() : CredentialValidator()
        
        // Initialize tracker
        self.tracker = AuthTracker(
            logger: logger
        )
        
        // Initialize use cases
        self.loginUseCase = LoginUseCase(
            repository: repository,
            validator: validator,
            logger: logger
        )
        
        self.refreshTokenUseCase = RefreshTokenUseCase(
            repository: repository,
            logger: logger
        )
        
        self.logoutUseCase = LogoutUseCase(
            repository: repository,
            logger: logger
        )
        
        // Initialize auto refresh manager
        self.autoRefreshManager = AutoRefreshManager(
            refreshUseCase: refreshTokenUseCase,
            logger: logger,
            refreshInterval: configuration.autoRefreshInterval
        )
        
        logger.log(.info, "AuthenticationModule initialized successfully")
    }
    
    // MARK: - Public Methods
    
    /**
     * Verifica si el usuario está autenticado.
     * 
     * - Returns: true si está autenticado, false en caso contrario
     */
    public func isAuthenticated() async -> Bool {
        return await repository.isAuthenticated()
    }
    
    /**
     * Obtiene la sesión actual del usuario.
     * 
     * - Returns: Sesión actual si existe, nil en caso contrario
     * - Throws: AuthError si hay un error al obtener la sesión
     */
    public func getCurrentSession() async throws -> AuthSession? {
        return try await repository.getCurrentSession()
    }
    
    /**
     * Realiza el login del usuario.
     * 
     * - Parameter credentials: Credenciales del usuario
     * - Returns: Sesión de autenticación exitosa
     * - Throws: AuthError si el login falla
     */
    public func login(credentials: LoginCredentials) async throws -> AuthSession {
        let session = try await loginUseCase.execute(credentials: credentials)
        
        // Start auto refresh if enabled
        if configuration.enableAutoRefresh {
            autoRefreshManager.startAutoRefresh()
        }
        
        return session
    }
    
    /**
     * Cierra la sesión del usuario.
     * 
     * - Parameter reason: Razón del logout (opcional)
     * - Throws: AuthError si el logout falla
     */
    public func logout(reason: LogoutReason = .userInitiated) async throws {
        // Stop auto refresh
        autoRefreshManager.stopAutoRefresh()
        
        try await logoutUseCase.execute(reason: reason)
    }
    
    /**
     * Renueva el token de acceso si es necesario.
     * 
     * - Returns: Token renovado si se realizó la renovación, nil si no era necesario
     * - Throws: AuthError si la renovación falla
     */
    public func refreshTokenIfNeeded() async throws -> AuthToken? {
        return try await refreshTokenUseCase.execute()
    }
    
    /**
     * Fuerza la renovación del token.
     * 
     * - Returns: Token renovado
     * - Throws: AuthError si la renovación falla
     */
    public func forceRefreshToken() async throws -> AuthToken {
        return try await refreshTokenUseCase.forceRefresh()
    }
    
    /**
     * Obtiene el token de acceso actual.
     * 
     * - Returns: Token de acceso si existe y es válido, nil en caso contrario
     * - Throws: AuthError si hay un error al obtener el token
     */
    public func getAccessToken() async throws -> String? {
        return try await repository.getAccessToken()
    }
    
    /**
     * Valida las credenciales sin realizar login.
     * 
     * - Parameter credentials: Credenciales a validar
     * - Returns: Resultado de la validación
     */
    public func validateCredentials(_ credentials: LoginCredentials) -> ValidationResult {
        return loginUseCase.validateCredentials(credentials)
    }

    /**
     * Obtiene el estado del token actual.
     * 
     * - Returns: Información del estado del token
     * - Throws: AuthError si no hay sesión activa
     */
    public func getTokenStatus() async throws -> TokenStatus {
        return try await refreshTokenUseCase.getTokenStatus()
    }
    
    /**
     * Fuerza una verificación y renovación automática.
     */
    public func forceCheckAndRefresh() async {
        await autoRefreshManager.forceCheckAndRefresh()
    }
    
    /**
     * Inicia la renovación automática de tokens.
     */
    @MainActor
    public func startAutoRefresh() {
        autoRefreshManager.startAutoRefresh()
    }
    
    /**
     * Detiene la renovación automática de tokens.
     */
    @MainActor
    public func stopAutoRefresh() {
        autoRefreshManager.stopAutoRefresh()
    }
    
    /**
     * Limpia todos los datos de autenticación.
     * 
     * - Throws: AuthError si la limpieza falla
     */
    public func clearAllData() async throws {
        logger.log(.info, "All authentication data cleared")
    }
}

