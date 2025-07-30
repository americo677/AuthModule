//
//  AuthenticationConfiguration.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - AuthenticationConfiguration

/**
 * Configuración del módulo de autenticación.
 */
public struct AuthenticationConfiguration {
    
    // MARK: - API Configuration
    
    /// URL base de la API
    public let apiBaseURL: URL
    
    /// Timeout de red en segundos
    public let networkTimeout: TimeInterval
    
    /// Headers por defecto para las peticiones
    public let defaultHeaders: [String: String]
    
    /// Configuración SSL
    public let sslConfiguration: SSLConfiguration?
    
    // MARK: - Security Configuration
    
    /// Identificador del servicio de Keychain
    public let keychainServiceIdentifier: String
    
    /// Grupo de acceso de Keychain (opcional)
    public let keychainAccessGroup: String?
    
    /// Nivel de seguridad
    public let securityLevel: SecurityLevel
    
    /// Algoritmo de encriptación
    public let encryptionAlgorithm: EncryptionAlgorithm
    
    /// Tamaño de la clave de encriptación
    public let encryptionKeySize: Int
    
    // MARK: - Validation Configuration
    
    /// Usar validación mejorada de credenciales
    public let useEnhancedValidation: Bool
    
    // MARK: - Auto Refresh Configuration
    
    /// Habilitar renovación automática de tokens
    public let enableAutoRefresh: Bool
    
    /// Intervalo de verificación automática en segundos
    public let autoRefreshInterval: TimeInterval
    
    // MARK: - Logging Configuration
    
    /// Habilitar logging en consola
    public let enableConsoleLogging: Bool
    
    /// Habilitar logging en archivo
    public let enableFileLogging: Bool
    
    /// Ruta del archivo de log
    public let logFilePath: String?
    
    // MARK: - Initialization
    
    public init(
        apiBaseURL: URL,
        networkTimeout: TimeInterval = 30.0,
        defaultHeaders: [String: String] = [:],
        sslConfiguration: SSLConfiguration? = nil,
        keychainServiceIdentifier: String = "com.auth.module",
        keychainAccessGroup: String? = nil,
        securityLevel: SecurityLevel = .whenUnlockedThisDeviceOnly,
        encryptionAlgorithm: EncryptionAlgorithm = .aes256,
        encryptionKeySize: Int = 256,
        useEnhancedValidation: Bool = false,
        enableAutoRefresh: Bool = true,
        autoRefreshInterval: TimeInterval = 5 * 60,
        enableConsoleLogging: Bool = true,
        enableFileLogging: Bool = false,
        logFilePath: String? = nil
    ) {
        self.apiBaseURL = apiBaseURL
        self.networkTimeout = networkTimeout
        self.defaultHeaders = defaultHeaders
        self.sslConfiguration = sslConfiguration
        self.keychainServiceIdentifier = keychainServiceIdentifier
        self.keychainAccessGroup = keychainAccessGroup
        self.securityLevel = securityLevel
        self.encryptionAlgorithm = encryptionAlgorithm
        self.encryptionKeySize = encryptionKeySize
        self.useEnhancedValidation = useEnhancedValidation
        self.enableAutoRefresh = enableAutoRefresh
        self.autoRefreshInterval = autoRefreshInterval
        self.enableConsoleLogging = enableConsoleLogging
        self.enableFileLogging = enableFileLogging
        self.logFilePath = logFilePath
    }
}


