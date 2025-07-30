//
//  CredentialValidatorProtocol.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - CredentialValidatorProtocol

/**
 * Protocolo para validación de credenciales.
 */
public protocol CredentialValidatorProtocol {
    
    /**
     * Valida las credenciales de autenticación.
     *
     * - Parameter credentials: Credenciales a validar
     * - Returns: Resultado de la validación
     */
    func validateCredentials(_ credentials: LoginCredentials) -> ValidationResult
}


