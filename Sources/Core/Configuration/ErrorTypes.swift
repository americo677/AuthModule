//
//  ErrorTypes.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - SecureStorageError

/**
 * Errores específicos del almacenamiento seguro.
 */
public enum SecureStorageError: LocalizedError, Equatable {
    
    case saveFailed
    case readFailed
    case deleteFailed
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case dataCorrupted
    case insufficientSpace
    case accessDenied
    case itemNotFound
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Error al guardar datos"
        case .readFailed:
            return "Error al leer datos"
        case .deleteFailed:
            return "Error al eliminar datos"
        case .encryptionFailed:
            return "Error al encriptar datos"
        case .decryptionFailed:
            return "Error al desencriptar datos"
        case .keyGenerationFailed:
            return "Error al generar clave de encriptación"
        case .dataCorrupted:
            return "Datos corruptos"
        case .insufficientSpace:
            return "Espacio insuficiente"
        case .accessDenied:
            return "Acceso denegado"
        case .itemNotFound:
            return "Elemento no encontrado"
        }
    }
}

// MARK: - AuthError Extension

extension AuthError {
    
    public var errorDescription: String? {
        switch self {
        case .networkError:
            return "Error de conexión de red"
        case .serverError(let code):
            return "Error del servidor (\(code))"
        case .timeout:
            return "Tiempo de espera agotado"
        case .noInternetConnection:
            return "Sin conexión a internet"
        case .invalidCredentials:
            return "Credenciales inválidas"
        case .tokenExpired:
            return "Token expirado"
        case .tokenInvalid:
            return "Token inválido"
        case .refreshTokenExpired:
            return "Token de refresh expirado"
        case .notAuthorized:
            return "No autorizado"
        case .validationFailed(let errors):
            return errors.map { $0.localizedDescription }.joined(separator: ", ")
        case .invalidEmail:
            return "Email inválido"
        case .invalidPassword:
            return "Contraseña inválida"
        case .storageError:
            return "Error de almacenamiento"
        case .encryptionError:
            return "Error de encriptación"
        case .decryptionError:
            return "Error de desencriptación"
        case .noActiveSession:
            return "No hay sesión activa"
        case .sessionExpired:
            return "Sesión expirada"
        case .userInactive:
            return "Usuario inactivo"
        case .unknown:
            return "Error desconocido"
        case .configurationError:
            return "Error de configuración"
        case .decodingError:
            return "Error al decodificar"
        }
    }
} 