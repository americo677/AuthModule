//
//  AuthenticationModuleFactory.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - AuthenticationModuleFactory

/**
 * Factory para crear instancias del módulo de autenticación.
 */
@MainActor
public class AuthenticationModuleFactory {
    
    /**
     * Crea un módulo de autenticación con configuración por defecto.
     *
     * - Parameter apiBaseURL: URL base de la API
     * - Returns: Instancia del módulo de autenticación
     * - Throws: Error si la inicialización falla
     */
    public static func createDefaultModule(apiBaseURL: URL) throws -> AuthenticationModule {
        let configuration = AuthenticationConfiguration(apiBaseURL: apiBaseURL)
        return try AuthenticationModule(configuration: configuration)
    }
    
    /**
     * Crea un módulo de autenticación con configuración personalizada.
     *
     * - Parameter configuration: Configuración personalizada
     * - Returns: Instancia del módulo de autenticación
     * - Throws: Error si la inicialización falla
     */
    public static func createCustomModule(configuration: AuthenticationConfiguration) throws -> AuthenticationModule {
        return try AuthenticationModule(configuration: configuration)
    }
    
    /**
     * Crea un módulo de autenticación para desarrollo.
     *
     * - Parameter apiBaseURL: URL base de la API
     * - Returns: Instancia del módulo de autenticación
     * - Throws: Error si la inicialización falla
     */
    public static func createDevelopmentModule(apiBaseURL: URL) throws -> AuthenticationModule {
        let configuration = AuthenticationConfiguration(
            apiBaseURL: apiBaseURL,
            networkTimeout: 60.0,
            enableConsoleLogging: true,
            enableFileLogging: true,
            logFilePath: "auth_module.log"
        )
        return try AuthenticationModule(configuration: configuration)
    }
    
    /**
     * Crea un módulo de autenticación para producción.
     *
     * - Parameter apiBaseURL: URL base de la API
     * - Returns: Instancia del módulo de autenticación
     * - Throws: Error si la inicialización falla
     */
    public static func createProductionModule(apiBaseURL: URL) throws -> AuthenticationModule {
        let configuration = AuthenticationConfiguration(
            apiBaseURL: apiBaseURL,
            networkTimeout: 30.0,
            useEnhancedValidation: true,
            enableConsoleLogging: false,
            enableFileLogging: true,
            logFilePath: "/var/log/auth_module.log"
        )
        return try AuthenticationModule(configuration: configuration)
    }
}
