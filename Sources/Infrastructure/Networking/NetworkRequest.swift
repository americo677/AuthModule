//
//  NetworkRequest.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - NetworkRequest

/**
 * Estructura que representa una petición HTTP.
 */
public struct NetworkRequest: Sendable {
    
    /// URL de destino
    public let url: URL
    
    /// Método HTTP
    public let method: HTTPMethod
    
    /// Headers HTTP
    public let headers: [String: String]
    
    /// Cuerpo de la petición
    public let body: Data?
    
    /// Timeout en segundos
    public let timeout: TimeInterval
    
    /// Identificador único de la petición
    public let requestId: String
    
    public init(
        url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        timeout: TimeInterval = 30.0,
        requestId: String = UUID().uuidString
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
        self.timeout = timeout
        self.requestId = requestId
    }
}



