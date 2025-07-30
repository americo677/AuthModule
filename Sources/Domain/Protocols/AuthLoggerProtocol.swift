//
//  AuthLoggerProtocol.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - AuthLoggerProtocol

/**
 * Protocolo para logging de autenticación.
 */
public protocol AuthLoggerProtocol {
    
    /**
     * Registra un mensaje de log.
     *
     * - Parameters:
     *   - level: Nivel de logging
     *   - message: Mensaje a registrar
     *   - file: Archivo donde se originó el log (opcional)
     *   - function: Función donde se originó el log (opcional)
     *   - line: Línea donde se originó el log (opcional)
     */
    func log(
        _ level: LogLevel,
        _ message: String,
        file: String?,
        function: String?,
        line: Int?
    )
    
    /**
     * Registra un mensaje de log con información de contexto automática.
     *
     * - Parameters:
     *   - level: Nivel de logging
     *   - message: Mensaje a registrar
     */
    func log(
        _ level: LogLevel,
        _ message: String
    )
}


