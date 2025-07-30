//
//  MockCredentialValidator.swift
//  AuthModuleTests
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation
@testable import AuthModule

/**
 * Mock implementation de CredentialValidatorProtocol para pruebas unitarias.
 */
public class MockCredentialValidator: CredentialValidatorProtocol {
    
    // MARK: - Properties
    
    public var shouldSucceed: Bool = true
    public var shouldThrowError: ValidationError?
    public var mockValidationResult: ValidationResult?
    public var mockErrors: [ValidationError] = []
    
    // MARK: - Call Tracking
    
    public var validateEmailCallCount: Int = 0
    public var validatePasswordCallCount: Int = 0
    public var validateCredentialsCallCount: Int = 0
    
    public var lastValidatedEmail: String?
    public var lastValidatedPassword: String?
    public var lastValidatedCredentials: LoginCredentials?
    
    // MARK: - CredentialValidatorProtocol Implementation
    
    public func validateEmail(_ email: String) throws {
        validateEmailCallCount += 1
        lastValidatedEmail = email
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw ValidationError.invalidEmail
        }
    }
    
    public func validatePassword(_ password: String) throws {
        validatePasswordCallCount += 1
        lastValidatedPassword = password
        
        if let error = shouldThrowError {
            throw error
        }
        
        guard shouldSucceed else {
            throw ValidationError.invalidPassword
        }
    }
    
    public func validateCredentials(_ credentials: LoginCredentials) -> ValidationResult {
        validateCredentialsCallCount += 1
        lastValidatedCredentials = credentials
        
        if let result = mockValidationResult {
            return result
        }
        
        if shouldSucceed {
            return ValidationResult(isValid: true, errors: [])
        } else {
            return ValidationResult(isValid: false, errors: mockErrors.isEmpty ? [.invalidEmail] : mockErrors)
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     * Configura el mock para que falle con un error específico.
     */
    public func configureToFail(with error: ValidationError) {
        shouldSucceed = false
        shouldThrowError = error
    }
    
    /**
     * Configura el mock para que tenga éxito.
     */
    public func configureToSucceed() {
        shouldSucceed = true
        shouldThrowError = nil
        mockValidationResult = ValidationResult(isValid: true, errors: [])
    }
    
    /**
     * Configura el mock con un resultado de validación específico.
     */
    public func configureWithValidationResult(_ result: ValidationResult) {
        mockValidationResult = result
    }
    
    /**
     * Configura el mock con errores específicos.
     */
    public func configureWithErrors(_ errors: [ValidationError]) {
        mockErrors = errors
        shouldSucceed = false
    }
    
    /**
     * Resetea todas las propiedades de tracking.
     */
    public func reset() {
        validateEmailCallCount = 0
        validatePasswordCallCount = 0
        validateCredentialsCallCount = 0
        
        lastValidatedEmail = nil
        lastValidatedPassword = nil
        lastValidatedCredentials = nil
        
        shouldSucceed = true
        shouldThrowError = nil
        mockValidationResult = nil
        mockErrors.removeAll()
    }
} 