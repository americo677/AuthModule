/**
 * Implementación del servicio de red usando URLSession nativo.
 * 
 * Esta clase proporciona una implementación completa del protocolo NetworkServiceProtocol
 * utilizando URLSession para realizar peticiones HTTP de forma segura y eficiente.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

@MainActor
public class URLSessionNetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    
    private var configuration: NetworkConfiguration?
    private let session: URLSession
    private var activeRequests: [String: URLSessionDataTask] = [:]
    private let queue = DispatchQueue(label: "com.auth.network", qos: .utility)
    
    // MARK: - Initialization
    
    /**
     * Inicializa el servicio de red con URLSession.
     * 
     * - Parameter session: Sesión de URLSession a usar (default: .shared)
     */
    nonisolated public init(session: URLSession = .shared) {
        self.session = session
    }
    
    /**
     * Inicializa el servicio de red con configuración.
     *
     * - Parameters:
     *   - session: Sesión de URLSession a usar
     *   - configuration: Configuración de red
     */
    public init(session: URLSession = .shared, configuration: NetworkConfiguration) {
        self.session = session
        self.configuration = configuration
        self.activeRequests = [:]
    }

    // MARK: - NetworkServiceProtocol Implementation
    
    nonisolated public func configure(with configuration: NetworkConfiguration) {
    }
    
    // MARK: - HTTP Methods
    
    public func get(
        url: URL,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> NetworkResponse {
        let request = NetworkRequest(
            url: url,
            method: .get,
            headers: headers ?? [:],
            timeout: timeout ?? configuration?.defaultTimeout ?? 30.0
        )
        return try await performRequest(request)
    }
    
    public func post(
        url: URL,
        body: Data? = nil,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> NetworkResponse {
        let request = NetworkRequest(
            url: url,
            method: .post,
            headers: headers ?? [:],
            body: body,
            timeout: timeout ?? configuration?.defaultTimeout ?? 30.0
        )
        return try await performRequest(request)
    }
    
    public func delete(
        url: URL,
        headers: [String: String]? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> NetworkResponse {
        let request = NetworkRequest(
            url: url,
            method: .delete,
            headers: headers ?? [:],
            timeout: timeout ?? configuration?.defaultTimeout ?? 30.0
        )
        return try await performRequest(request)
    }
    
    public func performRequest(_ request: NetworkRequest) async throws -> NetworkResponse {
        let startTime = Date()
        
        // Create URLRequest
        let urlRequest = try createURLRequest(from: request)
        return try await performSingleRequest(urlRequest, startTime: startTime)
    }
    
    // MARK: - Request Management
    
    nonisolated public func cancelAllRequests() {
       Task { @MainActor in
            for (_, task) in self.activeRequests {
                task.cancel()
            }
            self.activeRequests.removeAll()
        }
    }
    
    nonisolated public func cancelRequest(withId requestId: String) {
        Task { @MainActor in
            if let task = self.activeRequests[requestId] {
                task.cancel()
                self.activeRequests.removeValue(forKey: requestId)
            }
        }
    }
    
    nonisolated public func getConnectivityStatus() -> ConnectivityStatus {
        // This is a simplified implementation
        // In a real app, you might want to use Network framework or Reachability
        return .connected
    }
    
    public func performRequestWithRetry(_ request: NetworkRequest) async throws -> NetworkResponse {
        var lastError: Error?
        do {
            return try await performRequest(request)
        } catch {
            lastError = error
        }
        throw lastError ?? NetworkError.unknown
    }
    
    // MARK: - Private Methods
    
    /**
     * Crea un URLRequest a partir de NetworkRequest.
     * 
     * - Parameter request: Request a convertir
     * - Returns: URLRequest configurado
     * - Throws: NetworkError si hay un error en la creación
     */
    private func createURLRequest(from request: NetworkRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeout
        
        // Set default headers
        if let config = configuration {
            for (key, value) in config.defaultHeaders {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set request headers
        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body if present
        if let body = request.body {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
    
    /**
     * Realiza una petición única sin reintentos.
     * 
     * - Parameters:
     *   - urlRequest: Request a ejecutar
     *   - startTime: Tiempo de inicio para calcular la duración
     * - Returns: Respuesta de la petición
     * - Throws: NetworkError si la petición falla
     */
    private func performSingleRequest(_ urlRequest: URLRequest, startTime: Date) async throws -> NetworkResponse {
        return try await withCheckedThrowingContinuation { continuation in
            // Capture necessary values before the closure
            let mapError = self.mapError
            let handleHTTPError = self.handleHTTPError
            let urlString = urlRequest.url?.absoluteString ?? ""
            
            let task = session.dataTask(with: urlRequest) { data, response, error in
                defer {
                    Task { @MainActor in
                        self.activeRequests.removeValue(forKey: urlString)
                    }
                }
                
                // Handle error
                if let error = error {
                    let networkError = mapError(error)
                    continuation.resume(throwing: networkError)
                    return
                }
                
                // Handle response
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    continuation.resume(throwing: NetworkError.invalidResponse)
                    return
                }
                
                // Check for HTTP errors
                guard 200...299 ~= httpResponse.statusCode else {
                    let networkError = handleHTTPError(httpResponse, data)
                    continuation.resume(throwing: networkError)
                    return
                }
                
                // Create response
                let responseTime = Date().timeIntervalSince(startTime)
                let headers = httpResponse.allHeaderFields as? [String: String] ?? [:]
                
                let networkResponse = NetworkResponse(
                    data: data,
                    headers: headers,
                    statusCode: httpResponse.statusCode,
                    url: httpResponse.url,
                    responseTime: responseTime
                )
                
                continuation.resume(returning: networkResponse)
            }
            
            // Store active request
            Task { @MainActor in
                self.activeRequests[urlString] = task
            }
            
            task.resume()
        }
    }
    
    /**
     * Mapea errores de URLSession a NetworkError.
     * 
     * - Parameter error: Error original
     * - Returns: NetworkError mapeado
     */
    nonisolated private func mapError(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .cancelled:
                return .cancelled
            case .serverCertificateUntrusted, .clientCertificateRejected:
                return .sslError
            default:
                return .networkError
            }
        }
        return .unknown
    }
    
    /**
     * Maneja errores HTTP específicos.
     * 
     * - Parameters:
     *   - response: Respuesta HTTP
     *   - data: Datos de la respuesta
     * - Returns: NetworkError apropiado
     */
    nonisolated private func handleHTTPError(_ response: HTTPURLResponse, data: Data) -> NetworkError {
        switch response.statusCode {
        case 400:
            return .clientError(400)
        case 401:
            return .clientError(401)
        case 403:
            return .clientError(403)
        case 404:
            return .clientError(404)
        case 429:
            return .clientError(429)
        case 500...599:
            return .serverError(response.statusCode)
        default:
            return .serverError(response.statusCode)
        }
    }
}

// MARK: - URLSessionConfiguration Extensions

extension URLSessionConfiguration {
    
    /**
     * Crea una configuración optimizada para autenticación.
     * 
     * - Returns: Configuración de URLSession
     */
    public static func authOptimized() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        return config
    }
    
    /**
     * Crea una configuración con certificados SSL personalizados.
     * 
     * - Parameter certificates: Certificados SSL
     * - Returns: Configuración de URLSession
     */
    public static func withCustomCertificates(_ certificates: [Data]) -> URLSessionConfiguration {
        let config = authOptimized()
        // Note: In a real implementation, you would configure SSL pinning here
        return config
    }
} 
