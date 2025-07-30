/**
 * ViewModel para la pantalla de login.
 * 
 * Este ViewModel maneja la lógica de presentación para el login,
 * incluyendo validación de campos, estado de carga y manejo de errores.
 * 
 * - Author: Americo Cantillo Gutierrez
 * - Since: 1.0.0
 */

import Foundation
import Combine

public class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isLoggedIn: Bool = false
    @Published public var showPassword: Bool = false
    
    // MARK: - Validation Properties
    
    @Published public var emailValidationState: ValidationState = .idle
    @Published public var passwordValidationState: ValidationState = .idle
    @Published public var passwordStrength: PasswordStrength = .weak
    @Published public var passwordStrengthFeedback: [String] = []
    
    // MARK: - Dependencies
    
    private let loginUseCase: LoginUseCase
    private let credentialValidator: CredentialValidator
    private let tracker: AuthTracker
    private let logger: AuthLoggerProtocol
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var validationTimer: Timer?
    
    // MARK: - Initialization
    
    /**
     * Inicializa el ViewModel de login.
     * 
     * - Parameters:
     *   - loginUseCase: Caso de uso de login
     *   - credentialValidator: Validador de credenciales
     *   - tracker: Tracker de eventos
     *   - logger: Logger para trazabilidad
     */
    public init(
        loginUseCase: LoginUseCase,
        credentialValidator: CredentialValidator,
        tracker: AuthTracker,
        logger: AuthLoggerProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.credentialValidator = credentialValidator
        self.tracker = tracker
        self.logger = logger
        
        setupValidation()
    }
    
    // MARK: - Public Methods
    
    /**
     * Ejecuta el proceso de login.
     */
    public func login() async {
        guard !isLoading else { return }
        
        // Clear previous errors
        errorMessage = nil
        
        // Validate credentials
        let credentials = LoginCredentials(email: email, password: password)
        let validationResult = credentialValidator.validateCredentials(credentials)

        guard validationResult.isValid else {
            errorMessage = validationResult.errors.first?.localizedDescription
            tracker.trackLoginError(email: email, error: .validationFailed(validationResult.errors), source: .loginScreen)
            return
        }
        
        // Start loading
        isLoading = true
        
        do {
            // Track login attempt
            tracker.trackLoginAttempt(email: email, source: .loginScreen)
            
            let startTime = Date()
            
            // Perform login
            let session = try await loginUseCase.execute(credentials: credentials)
            
            let loginTime = Date().timeIntervalSince(startTime)
            
            // Track successful login
            tracker.trackLoginSuccess(user: session.user, loginTime: loginTime, source: .loginScreen)
            
            // Update state
            isLoggedIn = true
            isLoading = false
            
            logger.log(.info, "Login successful for \(email)")
            
        } catch {
            // Handle error
            isLoading = false
            handleLoginError(error)
        }
    }
    
    /**
     * Valida el email en tiempo real.
     */
    public func validateEmail() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            emailValidationState = .idle
        } else if credentialValidator.isValidEmail(trimmedEmail) {
            emailValidationState = .valid
        } else {
            emailValidationState = .invalid("Formato de email inválido")
        }
    }
    
    /**
     * Valida la contraseña en tiempo real.
     */
    public func validatePassword() {
        if password.isEmpty {
            passwordValidationState = .idle
            passwordStrength = .weak
            passwordStrengthFeedback = []
        } else {
            let analysis = credentialValidator.analyzePasswordStrength(password)
            passwordStrength = analysis.strength
            passwordStrengthFeedback = analysis.feedback
            
            if analysis.meetsMinimumRequirements {
                passwordValidationState = .valid
            } else {
                passwordValidationState = .invalid("La contraseña no cumple los requisitos mínimos")
            }
        }
    }
    
    /**
     * Alterna la visibilidad de la contraseña.
     */
    public func togglePasswordVisibility() {
        showPassword.toggle()
    }
    
    /**
     * Limpia el mensaje de error.
     */
    public func clearError() {
        errorMessage = nil
    }
    
    /**
     * Verifica si el formulario es válido.
     * 
     * - Returns: true si el formulario es válido, false en caso contrario
     */
    public var isFormValid: Bool {
        return emailValidationState == .valid &&
               passwordValidationState == .valid &&
               !email.isEmpty &&
               !password.isEmpty
    }
    
    /**
     * Obtiene el color del indicador de fortaleza de contraseña.
     * 
     * - Returns: Color como string
     */
    public var passwordStrengthColor: String {
        switch passwordStrength {
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
    
    /**
     * Obtiene el texto del botón de login.
     * 
     * - Returns: Texto del botón
     */
    public var loginButtonText: String {
        return isLoading ? "Iniciando sesión..." : "Iniciar sesión"
    }
    
    /**
     * Obtiene el texto del indicador de fortaleza de contraseña.
     * 
     * - Returns: Texto del indicador
     */
    public var passwordStrengthText: String {
        return passwordStrength.localizedDescription
    }
    
    // MARK: - Private Methods
    
    /**
     * Configura la validación en tiempo real.
     */
    private func setupValidation() {
        // Email validation with debounce
        $email
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateEmail()
            }
            .store(in: &cancellables)
        
        // Password validation with debounce
        $password
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validatePassword()
            }
            .store(in: &cancellables)
    }
    
    /**
     * Maneja errores de login.
     * 
     * - Parameter error: Error ocurrido
     */
    private func handleLoginError(_ error: Error) {
        let authError = mapError(error)
        
        switch authError {
        case .invalidCredentials:
            errorMessage = "Email o contraseña incorrectos"
        case .notAuthorized:
            errorMessage = "No tienes permisos para acceder"
        case .networkError:
            errorMessage = "Error de conexión. Verifica tu internet"
        case .timeout:
            errorMessage = "Tiempo de espera agotado. Intenta de nuevo"
        case .serverError:
            errorMessage = "Error del servidor. Intenta más tarde"
        case .validationFailed:
            errorMessage = "Datos de entrada inválidos"
        case .invalidEmail:
            errorMessage = "Email inválido"
        case .invalidPassword:
            errorMessage = "Contraseña inválida"
        default:
            errorMessage = "Error inesperado. Intenta de nuevo"
        }
        
        tracker.trackLoginError(email: email, error: authError, source: .loginScreen)
        logger.log(.error, "Login failed for \(email): \(authError.localizedDescription)")
    }
    
    /**
     * Mapea errores específicos a AuthError.
     * 
     * - Parameter error: Error original
     * - Returns: AuthError mapeado
     */
    private func mapError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        
        // Map other errors to generic error
        return .unknown
    }
    
    /**
     * Formatea el tiempo en formato legible.
     * 
     * - Parameter timeInterval: Tiempo en segundos
     * - Returns: String formateado
     */
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - ValidationState

/**
 * Estados de validación de campos.
 */
public enum ValidationState: Equatable {
    
    case idle
    case valid
    case invalid(String)
    
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .idle, .invalid:
            return false
        }
    }
    
    public var errorMessage: String? {
        switch self {
        case .invalid(let message):
            return message
        case .idle, .valid:
            return nil
        }
    }
}

// MARK: - LoginViewModel Extensions

extension LoginViewModel {
    
    /**
     * Configuración para testing.
     */
    public func configureForTesting() {
        // Reset all state
        email = ""
        password = ""
        isLoading = false
        errorMessage = nil
        isLoggedIn = false
        showPassword = false
        emailValidationState = .idle
        passwordValidationState = .idle
        passwordStrength = .weak
        passwordStrengthFeedback = []
        
        // Cancel all subscriptions
        cancellables.removeAll()
    }
    
    /**
     * Simula un login exitoso para testing.
     */
    public func simulateSuccessfulLogin() {
        isLoggedIn = true
        isLoading = false
        errorMessage = nil
    }
    
    /**
     * Simula un error de login para testing.
     * 
     * - Parameter error: Error a simular
     */
    public func simulateLoginError(_ error: AuthError) {
        handleLoginError(error)
        isLoading = false
    }
} 
