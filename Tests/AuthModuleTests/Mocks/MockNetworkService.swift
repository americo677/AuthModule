//
//  MockNetworkService.swift
//  AuthModuleTests
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation
@testable import AuthModule

/**
 * Mock implementation de NetworkServiceProtocol para pruebas unitarias.
 */
public final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    
    // MARK: - Properties
    
    public var shouldSucceed: Bool = true
    public var shouldThrowError: NetworkError?
    public var mockResponse: Any?
    public var isConnected: Bool = true
    
    // MARK: - Call Tracking
    
    public var getCallCount: Int = 0
    public var postCallCount: Int = 0
    public var deleteCallCount: Int = 0
    
    public var lastGetURL: URL?
    public var lastPostURL: URL?
    public var lastDeleteURL: URL?
    public var lastPostBody: Data?
    public var lastHeaders: [String: String]?
    
    // MARK: - NetworkServiceProtocol Implementation
    
    public func configure(with configuration: NetworkConfiguration) {
        // Mock implementation
    }
    
    public func get(
        url: URL,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> NetworkResponse {
        getCallCount += 1
        lastGetURL = url
        lastHeaders = headers
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw NetworkError.networkError
        }
        
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        let mockData = createMockData()
        
        return NetworkResponse(
            data: mockData,
            headers: ["Content-Type": "application/json"],
            statusCode: 200,
            url: url,
            responseTime: 0.1
        )
    }
    
    public func post(
        url: URL,
        body: Data? = nil,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> NetworkResponse {
        postCallCount += 1
        lastPostURL = url
        lastHeaders = headers
        lastPostBody = body
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw NetworkError.networkError
        }
        
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        let mockData = createMockData()
        
        return NetworkResponse(
            data: mockData,
            headers: ["Content-Type": "application/json"],
            statusCode: 200,
            url: url,
            responseTime: 0.1
        )
    }
    
    public func delete(
        url: URL,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> NetworkResponse {
        deleteCallCount += 1
        lastDeleteURL = url
        lastHeaders = headers
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw NetworkError.networkError
        }
        
        guard isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        let mockData = createMockData()
        
        return NetworkResponse(
            data: mockData,
            headers: ["Content-Type": "application/json"],
            statusCode: 200,
            url: url,
            responseTime: 0.1
        )
    }
    
    public func performRequest(_ request: NetworkRequest) async throws -> NetworkResponse {
        // Mock implementation
        return try await get(url: request.url, headers: request.headers, timeout: request.timeout)
    }
    
    public func cancelAllRequests() {
        // Mock implementation
    }
    
    public func cancelRequest(withId requestId: String) {
        // Mock implementation
    }
    
    public func getConnectivityStatus() -> ConnectivityStatus {
        return isConnected ? .connected : .disconnected
    }
    
    // MARK: - Helper Methods
    
    /**
     * Configura el mock para que tenga éxito.
     */
    public func configureToSucceed() {
        shouldSucceed = true
        shouldThrowError = nil
        isConnected = true
    }
    
    /**
     * Configura el mock para que falle con un error específico.
     */
    public func configureToFail(with error: NetworkError) {
        shouldSucceed = false
        shouldThrowError = error
    }
    
    /**
     * Configura el mock para simular falta de conectividad.
     */
    public func configureNoConnection() {
        isConnected = false
    }
    
    /**
     * Configura el mock con una respuesta específica.
     */
    public func configureWithResponse(_ response: Any) {
        mockResponse = response
    }
    
    /**
     * Crea datos mock para las respuestas.
     */
    private func createMockData() -> Data {
        if let mockResponse = mockResponse {
            do {
                if let encodable = mockResponse as? Encodable {
                    return try JSONEncoder().encode(encodable)
                }
            } catch {
                return Data()
            }
        }
        
        // Default mock data
        let defaultResponse: [String: Any] = ["success": true, "message": "Mock response"]
        return (try? JSONSerialization.data(withJSONObject: defaultResponse)) ?? Data()
    }
    
    /**
     * Resetea todas las propiedades de tracking.
     */
    public func reset() {
        getCallCount = 0
        postCallCount = 0
        deleteCallCount = 0
        
        lastGetURL = nil
        lastPostURL = nil
        lastDeleteURL = nil
        lastPostBody = nil
        lastHeaders = nil
        
        shouldSucceed = true
        shouldThrowError = nil
        mockResponse = nil
        isConnected = true
    }
} 
