//
//  NetworkServiceProtocol.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 29/07/25.
//

/**
 * Protocolo que define las operaciones de servicios de red.
 * 
 * Este protocolo permite implementar diferentes clientes HTTP (URLSession, Alamofire, etc.)
 * manteniendo la lógica de negocio desacoplada de la implementación específica.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

public protocol NetworkServiceProtocol: Sendable {
    
    // MARK: - Configuration
    
    /**
     * Configura el servicio de red con los parámetros especificados.
     * 
     * - Parameter configuration: Configuración del servicio de red
     */
    func configure(with configuration: NetworkConfiguration)
    
    // MARK: - HTTP Methods
    
    /**
     * Realiza una petición GET.
     * 
     * - Parameters:
     *   - url: URL de destino
     *   - headers: Headers HTTP opcionales
     *   - timeout: Timeout en segundos (opcional)
     * - Returns: Respuesta de la petición
     * - Throws: NetworkError si la petición falla
     */
    func get(
        url: URL,
        headers: [String: String]?,
        timeout: TimeInterval?
    ) async throws -> NetworkResponse
    
    /**
     * Realiza una petición POST.
     * 
     * - Parameters:
     *   - url: URL de destino
     *   - body: Cuerpo de la petición
     *   - headers: Headers HTTP opcionales
     *   - timeout: Timeout en segundos (opcional)
     * - Returns: Respuesta de la petición
     * - Throws: NetworkError si la petición falla
     */
    func post(
        url: URL,
        body: Data?,
        headers: [String: String]?,
        timeout: TimeInterval?
    ) async throws -> NetworkResponse
    
    /**
     * Realiza una petición DELETE.
     * 
     * - Parameters:
     *   - url: URL de destino
     *   - headers: Headers HTTP opcionales
     *   - timeout: Timeout en segundos (opcional)
     * - Returns: Respuesta de la petición
     * - Throws: NetworkError si la petición falla
     */
    func delete(
        url: URL,
        headers: [String: String]?,
        timeout: TimeInterval?
    ) async throws -> NetworkResponse
    
    // MARK: - Generic Request Method
    
    /**
     * Realiza una petición HTTP genérica.
     * 
     * - Parameter request: Petición HTTP configurada
     * - Returns: Respuesta de la petición
     * - Throws: NetworkError si la petición falla
     */
    func performRequest(_ request: NetworkRequest) async throws -> NetworkResponse
    
    // MARK: - Request Management
    
    /**
     * Cancela todas las peticiones en curso.
     */
    func cancelAllRequests()
    
    /**
     * Cancela una petición específica.
     * 
     * - Parameter requestId: Identificador de la petición
     */
    func cancelRequest(withId requestId: String)
    
    /**
     * Obtiene el estado de conectividad de red.
     * 
     * - Returns: Estado actual de la conectividad
     */
    func getConnectivityStatus() -> ConnectivityStatus
}

// MARK: - HTTPMethod

/**
 * Métodos HTTP soportados para autenticación.
 */
public enum HTTPMethod: String, CaseIterable, Sendable {
    
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    
    public var description: String {
        return rawValue
    }
    
    public var allowsBody: Bool {
        switch self {
        case .get:
            return false
        case .post, .delete:
            return true
        }
    }
}

// MARK: - ConnectivityStatus

/**
 * Estados de conectividad de red.
 */
public enum ConnectivityStatus: Sendable {
    
    case connected
    case disconnected
    case connecting
    case unknown
    
    public var description: String {
        switch self {
        case .connected:
            return "Conectado"
        case .disconnected:
            return "Desconectado"
        case .connecting:
            return "Conectando"
        case .unknown:
            return "Desconocido"
        }
    }
}

// MARK: - NetworkError

/**
 * Errores específicos de red.
 */
public enum NetworkError: LocalizedError, Equatable, Sendable {
    
    case invalidURL
    case noInternetConnection
    case timeout
    case serverError(Int)
    case clientError(Int)
    case invalidResponse
    case decodingError
    case encodingError
    case sslError
    case cancelled
    case networkError
    case unknown
    
}
