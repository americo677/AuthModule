//
//  NetworkConfiguration.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - NetworkConfiguration

/**
 * Configuración para el servicio de red.
 */
public struct NetworkConfiguration {
    
    /// URL base de la API
    public let baseURL: URL
    
    /// Timeout por defecto en segundos
    public let defaultTimeout: TimeInterval
    
    /// Headers por defecto para las peticiones
    public let defaultHeaders: [String: String]
    
    /// Configuración de reintentos
    public let defaultRetryConfiguration: RetryConfiguration?
    
    /// Configuración SSL
    public let sslConfiguration: SSLConfiguration?
    
    /// Configuración de caché
    public let cacheConfiguration: CacheConfiguration?
    
    public init(
        baseURL: URL,
        defaultTimeout: TimeInterval = 30.0,
        defaultHeaders: [String: String] = [:],
        defaultRetryConfiguration: RetryConfiguration? = nil,
        sslConfiguration: SSLConfiguration? = nil,
        cacheConfiguration: CacheConfiguration? = nil
    ) {
        self.baseURL = baseURL
        self.defaultTimeout = defaultTimeout
        self.defaultHeaders = defaultHeaders
        self.defaultRetryConfiguration = defaultRetryConfiguration
        self.sslConfiguration = sslConfiguration
        self.cacheConfiguration = cacheConfiguration
    }
}

// MARK: - RetryConfiguration

/**
 * Configuración para reintentos de peticiones de red.
 */
public struct RetryConfiguration {
    
    /// Número máximo de reintentos
    public let maxRetries: Int
    
    /// Tiempo base de espera entre reintentos (en segundos)
    public let baseDelay: TimeInterval
    
    /// Factor de multiplicación para el delay exponencial
    public let backoffMultiplier: Double
    
    /// Tiempo máximo de espera entre reintentos
    public let maxDelay: TimeInterval
    
    /// Códigos de estado HTTP que deben reintentarse
    public let retryableStatusCodes: Set<Int>
    
    public init(
        maxRetries: Int = 3,
        baseDelay: TimeInterval = 1.0,
        backoffMultiplier: Double = 2.0,
        maxDelay: TimeInterval = 30.0,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    ) {
        self.maxRetries = maxRetries
        self.baseDelay = baseDelay
        self.backoffMultiplier = backoffMultiplier
        self.maxDelay = maxDelay
        self.retryableStatusCodes = retryableStatusCodes
    }
}

// MARK: - SSLConfiguration

/**
 * Configuración SSL para conexiones seguras.
 */
public struct SSLConfiguration {
    
    /// Habilitar validación de certificados
    public let validateCertificates: Bool
    
    /// Habilitar validación de nombre de dominio
    public let validateHostname: Bool
    
    /// Certificados adicionales para confiar
    public let additionalTrustedCertificates: [Data]?
    
    public init(
        validateCertificates: Bool = true,
        validateHostname: Bool = true,
        additionalTrustedCertificates: [Data]? = nil
    ) {
        self.validateCertificates = validateCertificates
        self.validateHostname = validateHostname
        self.additionalTrustedCertificates = additionalTrustedCertificates
    }
}

// MARK: - CacheConfiguration

/**
 * Configuración de caché para respuestas de red.
 */
public struct CacheConfiguration {
    
    /// Tamaño máximo del caché en bytes
    public let maxCacheSize: Int
    
    /// Tiempo de vida de los elementos en caché (en segundos)
    public let cacheLifetime: TimeInterval
    
    /// Habilitar caché en disco
    public let enableDiskCache: Bool
    
    /// Habilitar caché en memoria
    public let enableMemoryCache: Bool
    
    public init(
        maxCacheSize: Int = 50 * 1024 * 1024, // 50 MB
        cacheLifetime: TimeInterval = 300, // 5 minutos
        enableDiskCache: Bool = true,
        enableMemoryCache: Bool = true
    ) {
        self.maxCacheSize = maxCacheSize
        self.cacheLifetime = cacheLifetime
        self.enableDiskCache = enableDiskCache
        self.enableMemoryCache = enableMemoryCache
    }
} 