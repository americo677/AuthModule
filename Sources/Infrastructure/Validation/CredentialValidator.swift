/**
 * Implementación del validador de credenciales.
 * 
 * Esta clase proporciona validación robusta de emails y contraseñas,
 * incluyendo validación de formato, fortaleza y requisitos de seguridad.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation

public class CredentialValidator: CredentialValidatorProtocol {
    
    // MARK: - Properties
    
    private let emailRegex: String
    private let passwordRegex: String
    private let minPasswordLength: Int
    private let maxPasswordLength: Int
    
    // MARK: - Initialization
    
    /**
     * Inicializa el validador con configuración personalizada.
     * 
     * - Parameters:
     *   - emailRegex: Expresión regular para validar emails
     *   - passwordRegex: Expresión regular para validar contraseñas
     *   - minPasswordLength: Longitud mínima de contraseña
     *   - maxPasswordLength: Longitud máxima de contraseña
     */
    public init(
        emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
        passwordRegex: String = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*?&]{8,}$",
        minPasswordLength: Int = 8,
        maxPasswordLength: Int = 128
    ) {
        self.emailRegex = emailRegex
        self.passwordRegex = passwordRegex
        self.minPasswordLength = minPasswordLength
        self.maxPasswordLength = maxPasswordLength
    }
    
    // MARK: - CredentialValidatorProtocol Implementation
    
    public func validateCredentials(_ credentials: LoginCredentials) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // Validate email
        if credentials.email.isEmpty {
            errors.append(.emptyEmail)
        } else if !isValidEmail(credentials.email) {
            errors.append(.invalidEmail)
        }
        
        // Validate password
        if credentials.password.isEmpty {
            errors.append(.emptyPassword)
        } else if !isValidPassword(credentials.password) {
            errors.append(.invalidPassword)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors
        )
    }
    
    // MARK: - Email Validation
    
    /**
     * Valida el formato de un email.
     * 
     * - Parameter email: Email a validar
     * - Returns: true si el email es válido, false en caso contrario
     */
    public func isValidEmail(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check basic format
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            return false
        }
        
        // Additional checks
        return isValidEmailFormat(trimmedEmail)
    }
    
    /**
     * Valida el formato de email con verificaciones adicionales.
     * 
     * - Parameter email: Email a validar
     * - Returns: true si el formato es válido, false en caso contrario
     */
    private func isValidEmailFormat(_ email: String) -> Bool {
        // Check for consecutive dots
        if email.contains("..") {
            return false
        }
        
        // Check for dots at start or end
        if email.hasPrefix(".") || email.hasSuffix(".") {
            return false
        }
        
        // Check domain length
        let components = email.components(separatedBy: "@")
        guard components.count == 2 else {
            return false
        }
        
        let domain = components[1]
        if domain.count > 253 || domain.count < 1 {
            return false
        }
        
        // Check for valid domain characters
        let domainRegex = "^[a-zA-Z0-9.-]+$"
        let domainPredicate = NSPredicate(format: "SELF MATCHES %@", domainRegex)
        guard domainPredicate.evaluate(with: domain) else {
            return false
        }
        
        return true
    }
    
    // MARK: - Password Validation
    
    /**
     * Valida la fortaleza de una contraseña.
     * 
     * - Parameter password: Contraseña a validar
     * - Returns: true si la contraseña es válida, false en caso contrario
     */
    public func isValidPassword(_ password: String) -> Bool {
        // Check length
        guard password.count >= minPasswordLength && password.count <= maxPasswordLength else {
            return false
        }
        
        // Check regex pattern
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        guard passwordPredicate.evaluate(with: password) else {
            return false
        }
        
        // Additional security checks
        return hasPasswordSecurityRequirements(password)
    }
    
    /**
     * Verifica que la contraseña cumpla con los requisitos de seguridad.
     * 
     * - Parameter password: Contraseña a verificar
     * - Returns: true si cumple los requisitos, false en caso contrario
     */
    private func hasPasswordSecurityRequirements(_ password: String) -> Bool {
        // Check for at least one letter
        let hasLetter = password.range(of: "[A-Za-z]", options: .regularExpression) != nil
        
        // Check for at least one digit
        let hasDigit = password.range(of: "\\d", options: .regularExpression) != nil
        
        // Check for no consecutive repeated characters
        let hasConsecutiveRepeats = password.range(of: "(.)\\1{2,}", options: .regularExpression) != nil
        
        // Check for common patterns
        let hasCommonPatterns = hasCommonPasswordPatterns(password)
        
        return hasLetter && hasDigit && !hasConsecutiveRepeats && !hasCommonPatterns
    }
    
    /**
     * Verifica si la contraseña contiene patrones comunes inseguros.
     * 
     * - Parameter password: Contraseña a verificar
     * - Returns: true si contiene patrones comunes, false en caso contrario
     */
    private func hasCommonPasswordPatterns(_ password: String) -> Bool {
        let commonPatterns = [
            "123", "abc", "qwe", "asd", "zxc",
            "password", "admin", "user", "test",
            "qwerty", "123456", "111111"
        ]
        
        let lowercasedPassword = password.lowercased()
        
        for pattern in commonPatterns {
            if lowercasedPassword.contains(pattern) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Password Strength Analysis
    
    /**
     * Analiza la fortaleza de una contraseña.
     * 
     * - Parameter password: Contraseña a analizar
     * - Returns: Análisis de fortaleza de la contraseña
     */
    public func analyzePasswordStrength(_ password: String) -> PasswordStrengthAnalysis {
        var score = 0
        var feedback: [String] = []
        
        // Length score
        if password.count >= 8 {
            score += 1
            if password.count >= 12 {
                score += 1
            }
        } else {
            feedback.append("La contraseña debe tener al menos 8 caracteres")
        }
        
        // Character variety score
        if password.range(of: "[a-z]", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("Incluir letras minúsculas")
        }
        
        if password.range(of: "[A-Z]", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("Incluir letras mayúsculas")
        }
        
        if password.range(of: "\\d", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("Incluir números")
        }
        
        if password.range(of: "[@$!%*?&]", options: .regularExpression) != nil {
            score += 1
        } else {
            feedback.append("Incluir caracteres especiales (@$!%*?&)")
        }
        
        // Deduct points for common patterns
        if hasCommonPasswordPatterns(password) {
            score = max(0, score - 2)
            feedback.append("Evitar patrones comunes")
        }
        
        // Determine strength level
        let strength: PasswordStrength
        switch score {
        case 0...2:
            strength = .weak
        case 3...4:
            strength = .medium
        case 5...6:
            strength = .strong
        default:
            strength = .veryStrong
        }
        
        return PasswordStrengthAnalysis(
            strength: strength,
            score: score,
            feedback: feedback
        )
    }
    
    // MARK: - Domain Validation
    
    /**
     * Valida el dominio de un email.
     * 
     * - Parameter email: Email a validar
     * - Returns: true si el dominio es válido, false en caso contrario
     */
    public func isValidEmailDomain(_ email: String) -> Bool {
        let components = email.components(separatedBy: "@")
        guard components.count == 2 else {
            return false
        }
        
        let domain = components[1]
        
        // Check for valid TLD
        let tldRegex = "\\.[a-zA-Z]{2,}$"
        let tldPredicate = NSPredicate(format: "SELF MATCHES %@", tldRegex)
        guard tldPredicate.evaluate(with: domain) else {
            return false
        }
        
        // Check for common disposable email domains
        let disposableDomains = [
            "10minutemail.com", "tempmail.org", "guerrillamail.com",
            "mailinator.com", "throwaway.email", "temp-mail.org"
        ]
        
        return !disposableDomains.contains(domain.lowercased())
    }
}

// MARK: - PasswordStrengthAnalysis

/**
 * Análisis de fortaleza de contraseña.
 */
public struct PasswordStrengthAnalysis {
    
    /// Nivel de fortaleza
    public let strength: PasswordStrength
    
    /// Puntuación numérica (0-6)
    public let score: Int
    
    /// Sugerencias de mejora
    public let feedback: [String]
    
    public init(strength: PasswordStrength, score: Int, feedback: [String]) {
        self.strength = strength
        self.score = score
        self.feedback = feedback
    }
    
    /**
     * Indica si la contraseña cumple los requisitos mínimos.
     * 
     * - Returns: true si cumple los requisitos, false en caso contrario
     */
    public var meetsMinimumRequirements: Bool {
        return score >= 3
    }
    
    /**
     * Obtiene el color asociado a la fortaleza.
     * 
     * - Returns: String con el color
     */
    public var color: String {
        switch strength {
        case .weak:
            return "red"
        case .medium:
            return "orange"
        case .strong:
            return "yellow"
        case .veryStrong:
            return "green"
        }
    }
}

// MARK: - PasswordStrength

/**
 * Niveles de fortaleza de contraseña.
 */
public enum PasswordStrength: String, CaseIterable {
    
    case weak = "weak"
    case medium = "medium"
    case strong = "strong"
    case veryStrong = "veryStrong"
    
    public var description: String {
        switch self {
        case .weak:
            return "Débil"
        case .medium:
            return "Media"
        case .strong:
            return "Fuerte"
        case .veryStrong:
            return "Muy Fuerte"
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .weak:
            return "La contraseña es muy débil. Se recomienda mejorarla."
        case .medium:
            return "La contraseña es moderadamente segura."
        case .strong:
            return "La contraseña es segura."
        case .veryStrong:
            return "La contraseña es muy segura."
        }
    }
}

// MARK: - EnhancedCredentialValidator

/**
 * Validador de credenciales con validación avanzada.
 */
public class EnhancedCredentialValidator: CredentialValidator {
    
    // MARK: - Properties
    
    private let requireSpecialCharacters: Bool
    private let requireUppercase: Bool
    private let requireLowercase: Bool
    private let requireNumbers: Bool
    private let maxConsecutiveCharacters: Int
    
    // MARK: - Initialization
    
    /**
     * Inicializa el validador mejorado.
     * 
     * - Parameters:
     *   - requireSpecialCharacters: Requiere caracteres especiales
     *   - requireUppercase: Requiere letras mayúsculas
     *   - requireLowercase: Requiere letras minúsculas
     *   - requireNumbers: Requiere números
     *   - maxConsecutiveCharacters: Máximo de caracteres consecutivos
     */
    public init(
        requireSpecialCharacters: Bool = true,
        requireUppercase: Bool = true,
        requireLowercase: Bool = true,
        requireNumbers: Bool = true,
        maxConsecutiveCharacters: Int = 3
    ) {
        self.requireSpecialCharacters = requireSpecialCharacters
        self.requireUppercase = requireUppercase
        self.requireLowercase = requireLowercase
        self.requireNumbers = requireNumbers
        self.maxConsecutiveCharacters = maxConsecutiveCharacters
        
        super.init(
            emailRegex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
            passwordRegex: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
            minPasswordLength: 8,
            maxPasswordLength: 128
        )
    }
    
    // MARK: - Override Methods
    
    public override func isValidPassword(_ password: String) -> Bool {
        // Check basic validation first
        guard super.isValidPassword(password) else {
            return false
        }
        
        // Check enhanced requirements
        return validateEnhancedPasswordRequirements(password)
    }
    
    // MARK: - Private Methods
    
    /**
     * Valida los requisitos mejorados de contraseña.
     * 
     * - Parameter password: Contraseña a validar
     * - Returns: true si cumple los requisitos, false en caso contrario
     */
    private func validateEnhancedPasswordRequirements(_ password: String) -> Bool {
        // Check for required character types
        if requireUppercase && password.range(of: "[A-Z]", options: .regularExpression) == nil {
            return false
        }
        
        if requireLowercase && password.range(of: "[a-z]", options: .regularExpression) == nil {
            return false
        }
        
        if requireNumbers && password.range(of: "\\d", options: .regularExpression) == nil {
            return false
        }
        
        if requireSpecialCharacters && password.range(of: "[@$!%*?&]", options: .regularExpression) == nil {
            return false
        }
        
        // Check for consecutive characters
        if hasTooManyConsecutiveCharacters(password) {
            return false
        }
        
        return true
    }
    
    /**
     * Verifica si hay demasiados caracteres consecutivos.
     * 
     * - Parameter password: Contraseña a verificar
     * - Returns: true si hay demasiados consecutivos, false en caso contrario
     */
    private func hasTooManyConsecutiveCharacters(_ password: String) -> Bool {
        let consecutiveRegex = "(.)\\1{\(maxConsecutiveCharacters),}"
        return password.range(of: consecutiveRegex, options: .regularExpression) != nil
    }
} 