//
//  AuthAPIServiceTests.swift
//  AuthModuleTests
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import XCTest
@testable import AuthModule

/**
 * Pruebas unitarias básicas para AuthAPIService.
 */
final class AuthAPIServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockNetworkService: MockNetworkService!
    private var mockLogger: MockAuthLogger!
    private var authAPIService: AuthAPIService!
    private let baseURL = URL(string: "https://api.example.com")!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Create mocks
        mockNetworkService = MockNetworkService()
        mockLogger = MockAuthLogger()
        
        // Create AuthAPIService
        authAPIService = AuthAPIService(
            networkService: mockNetworkService,
            baseURL: baseURL,
            logger: mockLogger
        )
    }
    
    override func tearDown() {
        mockNetworkService = nil
        mockLogger = nil
        authAPIService = nil
        
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testAuthAPIServiceInitialization() {
        // Given & When
        let service = AuthAPIService(
            networkService: mockNetworkService,
            baseURL: baseURL,
            logger: mockLogger
        )
        
        // Then
        XCTAssertNotNil(service)
    }
    
    // MARK: - Login Tests
    
    func testLoginSuccess() async throws {
        // Given
        let credentials = LoginCredentials(
            email: "test@example.com",
            password: "password123"
        )
        
        let expectedResponse = AuthResponse(
            user: User(
                id: "user123",
                email: "test@example.com",
                name: "Test User",
                isActive: true,
                createdAt: Date(),
                lastActivity: Date()
            ),
            token: AuthToken(
                accessToken: "access_token_123",
                refreshToken: "refresh_token_123",
                expiresIn: 3600,
                tokenType: "Bearer"
            ),
            message: "Login successful",
            requiresTwoFactor: false
        )
        
        mockNetworkService.configureToSucceed()
        mockNetworkService.configureWithResponse(expectedResponse)
        
        // When
        let response = try await authAPIService.login(credentials: credentials)
        
        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response.user.email, credentials.email)
        XCTAssertEqual(response.token.accessToken, "access_token_123")
        XCTAssertEqual(mockNetworkService.postCallCount, 1)
    }
    
    func testLoginFailure() async {
        // Given
        let credentials = LoginCredentials(
            email: "test@example.com",
            password: "wrongpassword"
        )
        
        mockNetworkService.configureToFail(with: NetworkError.networkError)
        
        // When & Then
        do {
            _ = try await authAPIService.login(credentials: credentials)
            XCTFail("Expected login to fail")
        } catch {
            // Should throw an error
            XCTAssertTrue(error is NetworkError || error is AuthError)
        }
        
        XCTAssertEqual(mockNetworkService.postCallCount, 1)
    }
    
    // MARK: - Refresh Token Tests
    
    func testRefreshTokenSuccess() async throws {
        // Given
        let refreshToken = "refresh_token_123"
        
        let expectedResponse = RefreshTokenResponse(
            token: AuthToken(
                accessToken: "new_access_token_123",
                refreshToken: "new_refresh_token_123",
                expiresIn: 3600,
                tokenType: "Bearer"
            ),
            message: "Token refreshed successfully"
        )
        
        mockNetworkService.configureToSucceed()
        mockNetworkService.configureWithResponse(expectedResponse)
        
        // When
        let response = try await authAPIService.refreshToken(refreshToken: refreshToken)
        
        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response.token.accessToken, "new_access_token_123")
        XCTAssertEqual(response.token.refreshToken, "new_refresh_token_123")
        XCTAssertEqual(mockNetworkService.postCallCount, 1)
    }
    
    func testRefreshTokenFailure() async {
        // Given
        let refreshToken = "expired_refresh_token"
        
        mockNetworkService.configureToFail(with: NetworkError.networkError)
        
        // When & Then
        do {
            _ = try await authAPIService.refreshToken(refreshToken: refreshToken)
            XCTFail("Expected refresh token to fail")
        } catch {
            // Should throw an error
            XCTAssertTrue(error is NetworkError || error is AuthError)
        }
        
        XCTAssertEqual(mockNetworkService.postCallCount, 1)
    }
    
    // MARK: - Logout Tests
    
    func testLogoutSuccess() async throws {
        // Given
        let accessToken = "access_token_123"
        
        mockNetworkService.configureToSucceed()
        
        // When
        try await authAPIService.logout(accessToken: accessToken)
        
        // Then
        XCTAssertEqual(mockNetworkService.getCallCount, 1)
    }
    
    func testLogoutFailure() async {
        // Given
        let accessToken = "invalid_token"
        
        mockNetworkService.configureToFail(with: NetworkError.networkError)
        
        // When & Then
        do {
            try await authAPIService.logout(accessToken: accessToken)
            XCTFail("Expected logout to fail")
        } catch {
            // Should throw an error
            XCTAssertTrue(error is NetworkError || error is AuthError)
        }
        
        XCTAssertEqual(mockNetworkService.getCallCount, 1)
    }
    
    // MARK: - Session Validation Tests
    
    func testValidateSessionSuccess() async throws {
        // Given
        let accessToken = "valid_token"
        
        let expectedResponse = SessionValidationResponse(
            isValid: true,
            user: User(
                id: "user123",
                email: "test@example.com",
                name: "Test User",
                isActive: true,
                createdAt: Date(),
                lastActivity: Date()
            ),
            expiresAt: Date().addingTimeInterval(3600),
            message: "Session is valid"
        )
        
        mockNetworkService.configureToSucceed()
        mockNetworkService.configureWithResponse(expectedResponse)
        
        // When
        let response = try await authAPIService.validateSession(accessToken: accessToken)
        
        // Then
        XCTAssertNotNil(response)
        XCTAssertTrue(response.isValid)
        XCTAssertEqual(response.user?.email, "test@example.com")
        XCTAssertEqual(mockNetworkService.getCallCount, 1)
    }
    
    func testValidateSessionFailure() async {
        // Given
        let accessToken = "invalid_token"
        
        mockNetworkService.configureToFail(with: NetworkError.networkError)
        
        // When & Then
        do {
            _ = try await authAPIService.validateSession(accessToken: accessToken)
            XCTFail("Expected session validation to fail")
        } catch {
            // Should throw an error
            XCTAssertTrue(error is NetworkError || error is AuthError)
        }
        
        XCTAssertEqual(mockNetworkService.getCallCount, 1)
    }
    
    // MARK: - Password Reset Tests
    
    func testRequestPasswordResetSuccess() async throws {
        // Given
        let email = "test@example.com"
        
        let expectedResponse = PasswordResetResponse(
            success: true,
            message: "Password reset email sent",
            emailSent: true
        )
        
        mockNetworkService.configureToSucceed()
        mockNetworkService.configureWithResponse(expectedResponse)
        
        // When
        let response = try await authAPIService.requestPasswordReset(email: email)
        
        // Then
        XCTAssertNotNil(response)
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Password reset email sent")
        XCTAssertEqual(mockNetworkService.postCallCount, 1)
    }
    
    func testRequestPasswordResetFailure() async {
        // Given
        let email = "nonexistent@example.com"
        
        mockNetworkService.configureToFail(with: NetworkError.networkError)
        
        // When & Then
        do {
            _ = try await authAPIService.requestPasswordReset(email: email)
            XCTFail("Expected password reset request to fail")
        } catch {
            // Should throw an error
            XCTAssertTrue(error is NetworkError || error is AuthError)
        }
        
        XCTAssertEqual(mockNetworkService.postCallCount, 1)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() async {
        // Given
        let credentials = LoginCredentials(
            email: "test@example.com",
            password: "password123"
        )
        
        mockNetworkService.configureToFail(with: NetworkError.networkError)
        
        // When & Then
        do {
            _ = try await authAPIService.login(credentials: credentials)
            XCTFail("Expected login to fail with network error")
        } catch {
            // Should throw an error
            XCTAssertTrue(error is NetworkError || error is AuthError)
        }
    }
    
    func testNoConnectionErrorHandling() async {
        // Given
        let credentials = LoginCredentials(
            email: "test@example.com",
            password: "password123"
        )
        
        mockNetworkService.configureNoConnection()
        
        // When & Then
        do {
            _ = try await authAPIService.login(credentials: credentials)
            XCTFail("Expected login to fail with no connection error")
        } catch {
            // Should throw an error
            XCTAssertTrue(error is NetworkError || error is AuthError)
        }
    }
} 