//
//  LogoutHandler.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - LogoutHandler

/**
 * Protocolo para handlers de logout.
 */
public protocol LogoutHandler: Sendable {
    
    /// Nombre del handler
    var name: String { get }
    
    /// Fase de ejecución del handler
    var executionPhase: LogoutExecutionPhase { get }
    
    /// Indica si el handler es crítico
    var isCritical: Bool { get }
    
    /**
     * Ejecuta el handler.
     *
     * - Parameter reason: Razón del logout
     * - Throws: Error si la ejecución falla
     */
    func execute(reason: LogoutReason) async throws
}

// MARK: - LogoutExecutionPhase

/**
 * Fases de ejecución de los handlers de logout.
 */
public enum LogoutExecutionPhase: Sendable {
    
    case preLogout
    case postLogout
}

