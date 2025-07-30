//
//  SecureStorageProtocol.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 29/07/25.
//

/**
 * Protocolo que define las operaciones de almacenamiento seguro.
 * 
 * Este protocolo permite implementar diferentes mecanismos de almacenamiento seguro
 * (Keychain, encriptación personalizada, etc.) manteniendo la lógica de negocio
 * desacoplada de la implementación específica.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

public protocol SecureStorageProtocol {
    
    // MARK: - Token Storage
    
    /**
     * Guarda un token de autenticación de forma segura.
     * 
     * - Parameter token: Token a guardar
     * - Throws: AuthError si hay un error al guardar
     */
    func saveToken(_ token: AuthToken) throws
    
    /**
     * Obtiene el token de autenticación guardado.
     * 
     * - Returns: Token guardado si existe, nil en caso contrario
     * - Throws: AuthError si hay un error al obtener el token
     */
    func getToken() throws -> AuthToken?
    
    /**
     * Elimina el token de autenticación guardado.
     * 
     * - Throws: AuthError si hay un error al eliminar
     */
    func clearToken() throws
    
    /**
     * Verifica si existe un token válido.
     * 
     * - Returns: true si existe un token válido, false en caso contrario
     */
    func hasValidToken() -> Bool
    
    // MARK: - General Storage Operations
    
    /**
     * Guarda cualquier dato de forma segura.
     * 
     * - Parameters:
     *   - data: Datos a guardar
     *   - key: Clave para identificar los datos
     * - Throws: AuthError si hay un error al guardar
     */
    func saveData(_ data: Data, forKey key: String) throws
    
    /**
     * Obtiene datos guardados de forma segura.
     * 
     * - Parameter key: Clave de los datos
     * - Returns: Datos guardados si existen, nil en caso contrario
     * - Throws: AuthError si hay un error al obtener
     */
    func getData(forKey key: String) throws -> Data?
    
    /**
     * Elimina datos guardados de forma segura.
     * 
     * - Parameter key: Clave de los datos
     * - Throws: AuthError si hay un error al eliminar
     */
    func deleteData(forKey key: String) throws
    
    /**
     * Verifica si existen datos para una clave específica.
     * 
     * - Parameter key: Clave única de los datos
     * - Returns: true si existen datos, false en caso contrario
     */
    func hasData(forKey key: String) -> Bool
    
    // MARK: - Storage Management
    
    /**
     * Limpia todos los datos almacenados de forma segura.
     * 
     * - Throws: AuthError si hay un error al limpiar
     */
    func clearAllData() throws
    
    /**
     * Obtiene el tamaño total de los datos almacenados.
     * 
     * - Returns: Tamaño en bytes de los datos almacenados
     * - Throws: AuthError si hay un error al calcular el tamaño
     */
    func getStorageSize() throws -> Int
    
    /**
     * Verifica la integridad de los datos almacenados.
     * 
     * - Returns: true si los datos están íntegros, false en caso contrario
     * - Throws: AuthError si hay un error al verificar
     */
    func verifyDataIntegrity() throws -> Bool
}

 
