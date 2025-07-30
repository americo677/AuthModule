//
//  NetworkResponse.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - NetworkResponse

/**
 * Estructura que representa una respuesta HTTP.
 */
public struct NetworkResponse: Sendable {
    
    /// Datos de la respuesta
    public let data: Data
    
    /// Headers de la respuesta
    public let headers: [String: String]
    
    /// Código de estado HTTP
    public let statusCode: Int
    
    /// URL de la respuesta
    public let url: URL?
    
    /// Tiempo de respuesta en segundos
    public let responseTime: TimeInterval
    
    public init(
        data: Data,
        headers: [String: String],
        statusCode: Int,
        url: URL?,
        responseTime: TimeInterval
    ) {
        self.data = data
        self.headers = headers
        self.statusCode = statusCode
        self.url = url
        self.responseTime = responseTime
    }
    
    /**
     * Verifica si la respuesta es exitosa (código 2xx).
     *
     * - Returns: true si la respuesta es exitosa, false en caso contrario
     */
    public var isSuccess: Bool {
        return statusCode >= 200 && statusCode < 300
    }
    
    /**
     * Verifica si la respuesta indica un error del cliente (código 4xx).
     *
     * - Returns: true si es un error del cliente, false en caso contrario
     */
    public var isClientError: Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    /**
     * Verifica si la respuesta indica un error del servidor (código 5xx).
     *
     * - Returns: true si es un error del servidor, false en caso contrario
     */
    public var isServerError: Bool {
        return statusCode >= 500 && statusCode < 600
    }
}
