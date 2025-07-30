//
//  StorageConfiguration.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - StorageConfiguration

/**
 * Configuración para el almacenamiento seguro.
 */
public struct StorageConfiguration {
    
    /// Identificador único del servicio de almacenamiento
    public let serviceIdentifier: String
    
    /// Grupo de acceso para compartir datos entre apps (opcional)
    public let accessGroup: String?
    
    /// Nivel de seguridad del almacenamiento
    public let securityLevel: SecurityLevel
    
    /// Algoritmo de encriptación a usar
    public let encryptionAlgorithm: EncryptionAlgorithm
    
    /// Tamaño de la clave de encriptación
    public let keySize: Int
    
    public init(
        serviceIdentifier: String,
        accessGroup: String? = nil,
        securityLevel: SecurityLevel = .whenUnlockedThisDeviceOnly,
        encryptionAlgorithm: EncryptionAlgorithm = .aes256,
        keySize: Int = 256
    ) {
        self.serviceIdentifier = serviceIdentifier
        self.accessGroup = accessGroup
        self.securityLevel = securityLevel
        self.encryptionAlgorithm = encryptionAlgorithm
        self.keySize = keySize
    }
}

// MARK: - SecurityLevel

/**
 * Niveles de seguridad para el almacenamiento.
 */
public enum SecurityLevel: String, CaseIterable {
    
    case whenUnlocked = "whenUnlocked"
    case whenUnlockedThisDeviceOnly = "whenUnlockedThisDeviceOnly"
    case afterFirstUnlock = "afterFirstUnlock"
    case afterFirstUnlockThisDeviceOnly = "afterFirstUnlockThisDeviceOnly"
    case always = "always"
    case alwaysThisDeviceOnly = "alwaysThisDeviceOnly"
    case whenPasscodeSetThisDeviceOnly = "whenPasscodeSetThisDeviceOnly"
    
    public var description: String {
        switch self {
        case .whenUnlocked:
            return "Solo cuando el dispositivo está desbloqueado"
        case .whenUnlockedThisDeviceOnly:
            return "Solo cuando el dispositivo está desbloqueado (este dispositivo)"
        case .afterFirstUnlock:
            return "Después del primer desbloqueo"
        case .afterFirstUnlockThisDeviceOnly:
            return "Después del primer desbloqueo (este dispositivo)"
        case .always:
            return "Siempre"
        case .alwaysThisDeviceOnly:
            return "Siempre (este dispositivo)"
        case .whenPasscodeSetThisDeviceOnly:
            return "Cuando hay código de acceso (este dispositivo)"
        }
    }
}

// MARK: - EncryptionAlgorithm

/**
 * Algoritmos de encriptación disponibles.
 */
public enum EncryptionAlgorithm: String, CaseIterable {
    
    case aes128 = "AES-128"
    case aes256 = "AES-256"
    case chaCha20 = "ChaCha20"
    case tripleDES = "3DES"
    
    public var description: String {
        return rawValue
    }
    
    public var keySize: Int {
        switch self {
        case .aes128:
            return 128
        case .aes256:
            return 256
        case .chaCha20:
            return 256
        case .tripleDES:
            return 168
        }
    }
} 