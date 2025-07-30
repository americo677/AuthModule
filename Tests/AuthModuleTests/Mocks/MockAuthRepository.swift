//
//  MockAuthRepository.swift
//  AuthModuleTests
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation
@testable import AuthModule

/**
 * Mock implementation de AuthRepositoryProtocol para pruebas unitarias.
 */
public class MockAuthRepository: AuthRepositoryProtocol {
    
    // MARK: - Properties
    
    public var shouldSucceed: Bool = true
    public var shouldThrowError: AuthError?
    public var mockSession: AuthSession?
    public var mockToken: AuthToken?
    public var mockTokenStatus: TokenStatus?
    public var isAuthenticatedResult: Bool = false
    
    // MARK: - Call Tracking
    
    public var loginCallCount: Int = 0
    public var logoutCallCount: Int = 0
    public var refreshTokenCallCount: Int = 0
    public var getCurrentSessionCallCount: Int = 0
    public var isAuthenticatedCallCount: Int = 0
    public var getAccessTokenCallCount: Int = 0
    public var refreshTokenIfNeededCallCount: Int = 0
    public var getTokenStatusCallCount: Int = 0
    
    public var lastLoginCredentials: LoginCredentials?
    public var lastLogoutReason: LogoutReason?
    public var lastRefreshToken: String?
    
    // MARK: - AuthRepositoryProtocol Implementation
    
    public func login(credentials: LoginCredentials) async throws -> AuthSession {
        loginCallCount += 1
        lastLoginCredentials = credentials
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw AuthError.invalidCredentials
        }
        
        return mockSession ?? AuthSession(
            user: User(
                id: "test-user-id",
                email: credentials.email,
                name: "Test User",
                isActive: true,
                createdAt: Date(),
                lastActivity: Date()
            ),
            token: AuthToken(
                accessToken: "mock-access-token",
                refreshToken: "mock-refresh-token",
                expiresIn: 3600,
                tokenType: "Bearer"
            )
        )
    }
    
    public func logout() async throws {
        logoutCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw AuthError.networkError
        }
    }
    
    public func logout(reason: LogoutReason) async throws {
        logoutCallCount += 1
        lastLogoutReason = reason
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw AuthError.networkError
        }
    }
    
    public func refreshToken(refreshToken: String) async throws -> AuthToken {
        refreshTokenCallCount += 1
        lastRefreshToken = refreshToken
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw AuthError.refreshTokenExpired
        }
        
        return mockToken ?? AuthToken(
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token",
            expiresIn: 3600,
            tokenType: "Bearer"
        )
    }
    
    public func getCurrentSession() async throws -> AuthSession? {
        getCurrentSessionCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockSession
    }
    
    public func isAuthenticated() async -> Bool {
        isAuthenticatedCallCount += 1
        return isAuthenticatedResult
    }
    
    public func getAccessToken() async throws -> String? {
        getAccessTokenCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockToken?.accessToken
    }
    
    public func refreshTokenIfNeeded() async throws -> Bool {
        refreshTokenIfNeededCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return shouldSucceed
    }
    
    public func needsTokenRefresh() async -> Bool {
        refreshTokenIfNeededCallCount += 1
        return shouldSucceed
    }
    
    public func getTokenStatus() async throws -> TokenStatus {
        getTokenStatusCallCount += 1
        
        if let error = shouldThrowError {
            throw error
        }
        
        return mockTokenStatus ?? TokenStatus(
            isExpired: false,
            willExpireSoon: false,
            timeUntilExpiration: 3600
        )
    }
    
    // MARK: - Helper Methods
    
    /**
     * Configura el mock para que falle con un error específico.
     */
    public func configureToFail(with error: AuthError) {
        shouldSucceed = false
        shouldThrowError = error
    }
    
    /**
     * Configura el mock para que tenga éxito.
     */
    public func configureToSucceed() {
        shouldSucceed = true
        shouldThrowError = nil
    }
    
    /**
     * Configura el mock con una sesión específica.
     */
    public func configureWithSession(_ session: AuthSession) {
        mockSession = session
    }
    
    /**
     * Configura el mock con un token específico.
     */
    public func configureWithToken(_ token: AuthToken) {
        mockToken = token
    }
    
    /**
     * Configura el mock con un estado de token específico.
     */
    public func configureWithTokenStatus(_ status: TokenStatus) {
        mockTokenStatus = status
    }
    
    /**
     * Configura el resultado de isAuthenticated.
     */
    public func configureIsAuthenticated(_ result: Bool) {
        isAuthenticatedResult = result
    }
    
    /**
     * Resetea todas las propiedades de tracking.
     */
    public func reset() {
        loginCallCount = 0
        logoutCallCount = 0
        refreshTokenCallCount = 0
        getCurrentSessionCallCount = 0
        isAuthenticatedCallCount = 0
        getAccessTokenCallCount = 0
        refreshTokenIfNeededCallCount = 0
        getTokenStatusCallCount = 0
        
        lastLoginCredentials = nil
        lastLogoutReason = nil
        lastRefreshToken = nil
        
        shouldSucceed = true
        shouldThrowError = nil
        mockSession = nil
        mockToken = nil
        mockTokenStatus = nil
        isAuthenticatedResult = false
    }
} 
