//
//  NetworkServiceFactory.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - NetworkServiceFactory

/**
 * Factory para crear diferentes implementaciones de NetworkServiceProtocol.
 */
public class NetworkServiceFactory {
    
    /**
     * Crea un servicio de red con URLSession.
     *
     * - Parameter configuration: Configuración opcional
     * - Returns: Instancia de NetworkServiceProtocol
     */
    public static func createURLSessionService(
        configuration: NetworkConfiguration? = nil
    ) -> NetworkServiceProtocol {
        let service = URLSessionNetworkService()
        if let config = configuration {
            service.configure(with: config)
        }
        return service
    }
    
    /**
     * Crea un servicio de red con configuración personalizada de URLSession.
     *
     * - Parameters:
     *   - sessionConfiguration: Configuración de URLSession
     *   - networkConfiguration: Configuración de red
     * - Returns: Instancia de NetworkServiceProtocol
     */
    public static func createCustomURLSessionService(
        sessionConfiguration: URLSessionConfiguration,
        networkConfiguration: NetworkConfiguration? = nil
    ) -> NetworkServiceProtocol {
        let session = URLSession(configuration: sessionConfiguration)
        let service = URLSessionNetworkService(session: session)
        if let config = networkConfiguration {
            service.configure(with: config)
        }
        return service
    }
}
