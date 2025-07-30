//
//  LoginViewModelFactory.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - LoginViewModelFactory

/**
 * Factory para crear ViewModels de login.
 */
public class LoginViewModelFactory {
    
    /**
     * Crea un ViewModel de login con configuración por defecto.
     *
     * - Parameters:
     *   - loginUseCase: Caso de uso de login
     *   - tracker: Tracker de eventos
     *   - logger: Logger para trazabilidad
     * - Returns: Instancia de LoginViewModel
     */
    public static func createDefaultViewModel(
        loginUseCase: LoginUseCase,
        tracker: AuthTracker,
        logger: AuthLoggerProtocol
    ) -> LoginViewModel {
        let validator = CredentialValidator()
        
        return LoginViewModel(
            loginUseCase: loginUseCase,
            credentialValidator: validator,
            tracker: tracker,
            logger: logger
        )
    }
    
    /**
     * Crea un ViewModel de login con validación mejorada.
     *
     * - Parameters:
     *   - loginUseCase: Caso de uso de login
     *   - tracker: Tracker de eventos
     *   - logger: Logger para trazabilidad
     * - Returns: Instancia de LoginViewModel
     */
    public static func createEnhancedViewModel(
        loginUseCase: LoginUseCase,
        tracker: AuthTracker,
        logger: AuthLoggerProtocol
    ) -> LoginViewModel {
        let validator = EnhancedCredentialValidator()
        
        return LoginViewModel(
            loginUseCase: loginUseCase,
            credentialValidator: validator,
            tracker: tracker,
            logger: logger
        )
    }
}

