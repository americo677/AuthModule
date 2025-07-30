//
//  AuthAPIServiceFactory.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - AuthAPIServiceFactory

/**
 * Factory para crear servicios de API de autenticación.
 */
public class AuthAPIServiceFactory {
    
    /**
     * Crea un servicio de API de autenticación con configuración por defecto.
     *
     * - Parameters:
     *   - baseURL: URL base de la API
     *   - logger: Logger para trazabilidad
     * - Returns: Instancia de AuthAPIService
     */
    public static func createDefaultService(
        baseURL: URL,
        logger: AuthLoggerProtocol
    ) -> AuthAPIService {
        let networkService = NetworkServiceFactory.createURLSessionService()
        return AuthAPIService(
            networkService: networkService,
            baseURL: baseURL,
            logger: logger
        )
    }
    
    /**
     * Crea un servicio de API de autenticación con configuración personalizada.
     *
     * - Parameters:
     *   - baseURL: URL base de la API
     *   - networkService: Servicio de red personalizado
     *   - logger: Logger para trazabilidad
     * - Returns: Instancia de AuthAPIService
     */
    public static func createCustomService(
        baseURL: URL,
        networkService: NetworkServiceProtocol,
        logger: AuthLoggerProtocol
    ) -> AuthAPIService {
        return AuthAPIService(
            networkService: networkService,
            baseURL: baseURL,
            logger: logger
        )
    }
}

