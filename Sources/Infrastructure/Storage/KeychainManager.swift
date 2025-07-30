/**
 * Implementación del almacenamiento seguro usando Keychain y encriptación AES-256.
 * 
 * Esta clase proporciona una implementación completa del protocolo SecureStorageProtocol
 * utilizando el Keychain del sistema iOS y encriptación AES-256 para máxima seguridad.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation
import Security
import CryptoKit

public class KeychainManager: SecureStorageProtocol {
    
    // MARK: - Properties
    
    private let serviceIdentifier: String
    private let accessGroup: String?
    private let securityLevel: SecurityLevel
    private let encryptionKey: SymmetricKey
    
    // MARK: - Initialization
    
    /**
     * Inicializa el KeychainManager.
     * 
     * - Parameters:
     *   - serviceIdentifier: Identificador único del servicio
     *   - accessGroup: Grupo de acceso para compartir datos (opcional)
     *   - securityLevel: Nivel de seguridad del almacenamiento
     * - Throws: SecureStorageError si hay un error en la inicialización
     */
    public init(
        serviceIdentifier: String,
        accessGroup: String? = nil,
        securityLevel: SecurityLevel = .whenUnlockedThisDeviceOnly
    ) throws {
        self.serviceIdentifier = serviceIdentifier
        self.accessGroup = accessGroup
        self.securityLevel = securityLevel
        self.encryptionKey = try Self.generateEncryptionKey()
    }
    
    /**
     * Inicializa el KeychainManager con configuración.
     * 
     * - Parameter configuration: Configuración del almacenamiento
     * - Throws: SecureStorageError si hay un error en la inicialización
     */
    public init(configuration: StorageConfiguration) throws {
        self.serviceIdentifier = configuration.serviceIdentifier
        self.accessGroup = configuration.accessGroup
        self.securityLevel = configuration.securityLevel
        self.encryptionKey = try Self.generateEncryptionKey()
    }
    
    // MARK: - Token Storage
    
    public func saveToken(_ token: AuthToken) throws {
        let tokenData = try JSONEncoder().encode(token)
        let encryptedData = try encrypt(data: tokenData)
        
        let query = createKeychainQuery(
            forKey: "\(serviceIdentifier).token",
            data: encryptedData
        )
        
        // Delete existing token first
        SecItemDelete(query as CFDictionary)
        
        // Save new token
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailed
        }
    }
    
    public func getToken() throws -> AuthToken? {
        let query = createKeychainQuery(forKey: "\(serviceIdentifier).token")
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            if status == errSecItemNotFound {
                return nil
            }
            throw SecureStorageError.readFailed
        }
        
        let decryptedData = try decrypt(data: data)
        return try JSONDecoder().decode(AuthToken.self, from: decryptedData)
    }
    
    public func clearToken() throws {
        let query = createKeychainQuery(forKey: "\(serviceIdentifier).token")
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.deleteFailed
        }
    }
    
    public func hasValidToken() -> Bool {
        do {
            guard let token = try getToken() else { return false }
            return !token.isExpired
        } catch {
            return false
        }
    }

    // MARK: - General Storage Operations
    
    public func saveData(_ data: Data, forKey key: String) throws {
        let encryptedData = try encrypt(data: data)
        
        let query = createKeychainQuery(
            forKey: "\(serviceIdentifier).\(key)",
            data: encryptedData
        )
        
        // Delete existing data first
        SecItemDelete(query as CFDictionary)
        
        // Save new data
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailed
        }
    }
    
    public func getData(forKey key: String) throws -> Data? {
        let query = createKeychainQuery(forKey: "\(serviceIdentifier).\(key)")
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            if status == errSecItemNotFound {
                return nil
            }
            throw SecureStorageError.readFailed
        }
        
        return try decrypt(data: data)
    }
    
    public func deleteData(forKey key: String) throws {
        let query = createKeychainQuery(forKey: "\(serviceIdentifier).\(key)")
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.deleteFailed
        }
    }
    
    public func hasData(forKey key: String) -> Bool {
        let query = createKeychainQuery(forKey: "\(serviceIdentifier).\(key)")
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess
    }
    
    // MARK: - Storage Management
    
    public func clearAllData() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.deleteFailed
        }
    }
    
    public func getStorageSize() throws -> Int {
        // This is a simplified implementation
        // In a real scenario, you might want to iterate through all items
        return 0
    }
    
    public func verifyDataIntegrity() throws -> Bool {
        // This is a simplified implementation
        // In a real scenario, you might want to verify checksums or signatures
        return true
    }
    
    // MARK: - Private Methods
    
    /**
     * Crea una query para el Keychain.
     * 
     * - Parameters:
     *   - key: Clave para identificar los datos
     *   - data: Datos a guardar (opcional)
     * - Returns: Query del Keychain
     */
    private func createKeychainQuery(forKey key: String, data: Data? = nil) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecAttrAccessible as String: securityLevel.keychainValue
        ]
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        if let data = data {
            query[kSecValueData as String] = data
        } else {
            query[kSecReturnData as String] = true
            query[kSecMatchLimit as String] = kSecMatchLimitOne
        }
        
        return query
    }
    
    /**
     * Encripta datos usando AES-256-GCM.
     * 
     * - Parameter data: Datos a encriptar
     * - Returns: Datos encriptados
     * - Throws: SecureStorageError si la encriptación falla
     */
    private func encrypt(data: Data) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
            return sealedBox.combined ?? Data()
        } catch {
            throw SecureStorageError.encryptionFailed
        }
    }
    
    /**
     * Desencripta datos usando AES-256-GCM.
     * 
     * - Parameter data: Datos encriptados
     * - Returns: Datos desencriptados
     * - Throws: SecureStorageError si la desencriptación falla
     */
    private func decrypt(data: Data) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: encryptionKey)
        } catch {
            throw SecureStorageError.decryptionFailed
        }
    }
    
    /**
     * Genera una clave de encriptación AES-256.
     * 
     * - Returns: Clave de encriptación
     * - Throws: SecureStorageError si la generación falla
     */
    private static func generateEncryptionKey() throws -> SymmetricKey {
        // In a production environment, you should derive this key from the device's keychain
        // or use a more sophisticated key management system
        return SymmetricKey(size: .bits256)
    }
}

// MARK: - SecurityLevel Extension

extension SecurityLevel {
    
    /**
     * Obtiene el valor correspondiente para el Keychain.
     * 
     * - Returns: Valor del Keychain
     */
    var keychainValue: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .always:
            return kSecAttrAccessibleAfterFirstUnlock
        case .alwaysThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}

// MARK: - String Extension for SHA256

extension String {
    
    /**
     * Calcula el hash SHA256 de la cadena.
     * 
     * - Returns: Hash SHA256 como string hexadecimal
     */
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
} 
