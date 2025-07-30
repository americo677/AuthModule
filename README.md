# AuthModule

[![Swift](https://img.shields.io/badge/Swift-6.1-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2010.15%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Una librería de autenticación robusta y segura para aplicaciones iOS, desarrollada en Swift con arquitectura limpia y patrones de diseño modernos.

## 📋 Características

- 🔐 **Autenticación completa**: Login, logout, refresh de tokens y validación de sesiones
- 🔒 **Seguridad avanzada**: Encriptación AES-256-GCM, almacenamiento seguro en Keychain
- 🏗️ **Arquitectura limpia**: Separación clara de capas (Domain, Data, Infrastructure, Presentation)
- 🧪 **Cobertura de tests**: Pruebas unitarias exhaustivas con mocks
- 📱 **Multiplataforma**: Soporte para iOS 15+ y macOS 10.15+
- 🔄 **Async/Await**: API moderna con soporte completo para concurrencia
- 📊 **Analytics**: Tracking de eventos de autenticación - WIP
- 🎯 **Validación**: Validación robusta de credenciales y inputs

## 🚀 Instalación

### Swift Package Manager

1. Abre tu proyecto en Xcode
2. Ve a `File` → `Add Package Dependencies...`
3. Pega la URL del repositorio:
   ```
   https://github.com/tu-usuario/AuthModule.git
   ```
4. Selecciona la versión deseada y haz clic en `Add Package`

### Manual

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/AuthModule.git
   ```
2. Arrastra la carpeta `AuthModule` a tu proyecto Xcode
3. Asegúrate de que esté incluida en tu target

## 🛠️ Compilación

### Requisitos

- Xcode 15.0+
- iOS 15.0+ / macOS 10.15+
- Swift 6.1+

### Compilar la librería

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/AuthModule.git
cd AuthModule

# Compilar el proyecto
swift build

# Compilar para release
swift build -c release
```

### Compilar con Xcode

1. Abre `AuthModule.xcodeproj` en Xcode
2. Selecciona el target `AuthModule`
3. Presiona `Cmd + B` para compilar

## 🧪 Ejecutar Tests

### Desde la línea de comandos

```bash
# Ejecutar todos los tests
swift test

# Ejecutar tests con output detallado
swift test --verbose

# Ejecutar tests específicos
swift test --filter AuthAPIServiceTests
```

### Desde Xcode

1. Abre `AuthModule.xcodeproj` en Xcode
2. Selecciona el target `AuthModuleTests`
3. Presiona `Cmd + U` para ejecutar los tests
4. Ve a `Product` → `Test` para ver los resultados

### Cobertura de Tests

```bash
# Ejecutar tests con cobertura
swift test --enable-code-coverage

# Ver reporte de cobertura
xcrun llvm-cov show -instr-profile .build/debug/codecov/default.profdata .build/debug/AuthModulePackageTests.xctest/Contents/MacOS/AuthModulePackageTests
```

## 📱 Uso en Proyectos iOS

### Configuración Inicial

```swift
import AuthModule

// Configurar el módulo de autenticación
let authModule = AuthenticationModule(
    baseURL: URL(string: "https://api.tuapp.com")!,
    networkService: URLSessionNetworkService(),
    secureStorage: KeychainManager(),
    logger: AuthLogger()
)
```

### Implementación con UIKit

#### 1. LoginViewController

```swift
import UIKit
import AuthModule

class LoginViewController: UIViewController {
    
    private let authModule: AuthenticationModule
    private let loginUseCase: LoginUseCase
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    init(authModule: AuthenticationModule) {
        self.authModule = authModule
        self.loginUseCase = authModule.loginUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        performLogin()
    }
    
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Por favor completa todos los campos")
            return
        }
        
        let credentials = LoginCredentials(email: email, password: password)
        
        // Validar credenciales
        let validation = credentials.validate()
        guard validation.isValid else {
            showAlert(message: validation.errors.first?.localizedDescription ?? "Error de validación")
            return
        }
        
        loginButton.isEnabled = false
        activityIndicator.startAnimating()
        
        Task {
            do {
                let result = try await loginUseCase.execute(credentials: credentials)
                
                await MainActor.run {
                    self.loginButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.handleLoginSuccess(result)
                }
            } catch {
                await MainActor.run {
                    self.loginButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.handleLoginError(error)
                }
            }
        }
    }
    
    private func handleLoginSuccess(_ result: LoginResult) {
        // Navegar a la pantalla principal
        let mainViewController = MainViewController(authModule: authModule)
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
    
    private func handleLoginError(_ error: Error) {
        let message: String
        
        if let authError = error as? AuthError {
            message = authError.localizedDescription
        } else {
            message = "Error inesperado: \(error.localizedDescription)"
        }
        
        showAlert(message: message)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

#### 2. MainViewController

```swift
import UIKit
import AuthModule

class MainViewController: UIViewController {
    
    private let authModule: AuthenticationModule
    private let logoutUseCase: LogoutUseCase
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    init(authModule: AuthenticationModule) {
        self.authModule = authModule
        self.logoutUseCase = authModule.logoutUseCase
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserInfo()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        performLogout()
    }
    
    private func performLogout() {
        logoutButton.isEnabled = false
        
        Task {
            do {
                try await logoutUseCase.execute()
                
                await MainActor.run {
                    self.logoutButton.isEnabled = true
                    self.handleLogoutSuccess()
                }
            } catch {
                await MainActor.run {
                    self.logoutButton.isEnabled = true
                    self.handleLogoutError(error)
                }
            }
        }
    }
    
    private func handleLogoutSuccess() {
        // Volver a la pantalla de login
        dismiss(animated: true)
    }
    
    private func handleLogoutError(_ error: Error) {
        showAlert(message: "Error al cerrar sesión: \(error.localizedDescription)")
    }
    
    private func loadUserInfo() {
        // Cargar información del usuario desde el almacenamiento seguro
        if let session = try? authModule.authRepository.getCurrentSession() {
            welcomeLabel.text = "Bienvenido, \(session.user.name)"
        }
    }
}
```

### Implementación con SwiftUI

#### 1. LoginView

```swift
import SwiftUI
import AuthModule

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(authModule: AuthenticationModule) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authModule: authModule))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Iniciar Sesión")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Contraseña", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button(action: performLogin) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isLoading ? "Iniciando sesión..." : "Iniciar Sesión")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .alert("Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onReceive(viewModel.$loginState) { state in
                handleLoginState(state)
            }
        }
    }
    
    private func performLogin() {
        isLoading = true
        let credentials = LoginCredentials(email: email, password: password)
        viewModel.login(credentials: credentials)
    }
    
    private func handleLoginState(_ state: LoginState) {
        isLoading = false
        
        switch state {
        case .success(let result):
            // Navegar a la vista principal
            break
        case .failure(let error):
            alertMessage = error.localizedDescription
            showAlert = true
        case .idle:
            break
        }
    }
}

// MARK: - LoginViewModel

@MainActor
class LoginViewModel: ObservableObject {
    @Published var loginState: LoginState = .idle
    
    private let loginUseCase: LoginUseCase
    
    init(authModule: AuthenticationModule) {
        self.loginUseCase = authModule.loginUseCase
    }
    
    func login(credentials: LoginCredentials) {
        Task {
            do {
                let result = try await loginUseCase.execute(credentials: credentials)
                loginState = .success(result)
            } catch {
                loginState = .failure(error)
            }
        }
    }
}

enum LoginState {
    case idle
    case success(LoginResult)
    case failure(Error)
}
```

#### 2. MainView

```swift
import SwiftUI
import AuthModule

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    @State private var showLogoutAlert = false
    
    init(authModule: AuthenticationModule) {
        _viewModel = StateObject(wrappedValue: MainViewModel(authModule: authModule))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = viewModel.currentUser {
                    VStack(spacing: 10) {
                        Text("Bienvenido")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(user.name)
                            .font(.title2)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Cerrar Sesión") {
                    showLogoutAlert = true
                }
                .foregroundColor(.red)
                .padding()
            }
            .padding()
            .navigationTitle("Inicio")
            .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar Sesión", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("¿Estás seguro de que quieres cerrar sesión?")
            }
            .onReceive(viewModel.$logoutState) { state in
                handleLogoutState(state)
            }
        }
    }
    
    private func handleLogoutState(_ state: LogoutState) {
        switch state {
        case .success:
            // Navegar de vuelta al login
            break
        case .failure(let error):
            // Mostrar error
            break
        case .idle:
            break
        }
    }
}

// MARK: - MainViewModel

@MainActor
class MainViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var logoutState: LogoutState = .idle
    
    private let logoutUseCase: LogoutUseCase
    private let authRepository: AuthRepositoryProtocol
    
    init(authModule: AuthenticationModule) {
        self.logoutUseCase = authModule.logoutUseCase
        self.authRepository = authModule.authRepository
        loadCurrentUser()
    }
    
    func logout() {
        Task {
            do {
                try await logoutUseCase.execute()
                logoutState = .success
            } catch {
                logoutState = .failure(error)
            }
        }
    }
    
    private func loadCurrentUser() {
        Task {
            if let session = try? await authRepository.getCurrentSession() {
                currentUser = session.user
            }
        }
    }
}

enum LogoutState {
    case idle
    case success
    case failure(Error)
}
```

#### 3. App Principal

```swift
import SwiftUI
import AuthModule

@main
struct MyApp: App {
    @StateObject private var authStateManager = AuthStateManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authStateManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authStateManager: AuthStateManager
    
    var body: some View {
        Group {
            if authStateManager.isAuthenticated {
                MainView(authModule: authStateManager.authModule)
            } else {
                LoginView(authModule: authStateManager.authModule)
            }
        }
        .onAppear {
            authStateManager.checkAuthenticationState()
        }
    }
}

class AuthStateManager: ObservableObject {
    @Published var isAuthenticated = false
    
    let authModule: AuthenticationModule
    
    init() {
        // Configurar el módulo de autenticación
        self.authModule = AuthenticationModule(
            baseURL: URL(string: "https://api.tuapp.com")!,
            networkService: URLSessionNetworkService(),
            secureStorage: KeychainManager(),
            logger: AuthLogger()
        )
    }
    
    func checkAuthenticationState() {
        Task {
            if let _ = try? await authModule.authRepository.getCurrentSession() {
                await MainActor.run {
                    self.isAuthenticated = true
                }
            }
        }
    }
}
```

## 🔧 Configuración Avanzada

### Configuración de Red

```swift
// Configurar timeouts personalizados
let networkService = URLSessionNetworkService()
networkService.configure(with: NetworkConfiguration(
    timeout: 30.0,
    retryCount: 3,
    enableLogging: true
))
```

### Configuración de Seguridad

```swift
// Configurar nivel de seguridad del Keychain
let keychainManager = KeychainManager()
keychainManager.configure(securityLevel: .whenUnlockedThisDeviceOnly)
```

### Configuración de Analytics

```swift
// Configurar tracking de eventos
let authTracker = AuthTracker()
authTracker.configure(
    enableTracking: true,
    trackPerformance: true,
    trackErrors: true
)
```

## 📚 API Reference

### AuthenticationModule

Clase principal que coordina todas las operaciones de autenticación.

```swift
class AuthenticationModule {
    let loginUseCase: LoginUseCase
    let logoutUseCase: LogoutUseCase
    let refreshTokenUseCase: RefreshTokenUseCase
    let authRepository: AuthRepositoryProtocol
    
    init(baseURL: URL, networkService: NetworkServiceProtocol, secureStorage: SecureStorageProtocol, logger: AuthLoggerProtocol)
}
```

### LoginUseCase

Maneja la lógica de negocio para el login.

```swift
func execute(credentials: LoginCredentials) async throws -> LoginResult
```

### LogoutUseCase

Maneja la lógica de negocio para el logout.

```swift
func execute() async throws
```

### RefreshTokenUseCase

Maneja la renovación automática de tokens.

```swift
func execute() async throws -> AuthToken
```

## 🐛 Troubleshooting

### Error: "CommonCrypto not found"

Si encuentras este error, asegúrate de que el `Package.swift` esté configurado correctamente:

```swift
linkerSettings: [
    .linkedFramework("Security")
]
```

### Error: "Network request failed"

Verifica que:
1. La URL base sea correcta
2. El dispositivo tenga conexión a internet
3. Los headers de autorización sean válidos

### Error: "Keychain access denied"

Asegúrate de que:
1. El app tenga permisos de Keychain
2. El nivel de seguridad sea apropiado
3. El dispositivo no esté bloqueado

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**Americo Cantillo Gutierrez:.**

- GitHub: [@americo677](https://github.com/americo677)

## 🙏 Agradecimientos

- [CryptoKit](https://developer.apple.com/documentation/cryptokit) - Para funcionalidades criptográficas
- [Keychain Services](https://developer.apple.com/documentation/security/keychain_services) - Para almacenamiento seguro
- [URLSession](https://developer.apple.com/documentation/foundation/urlsession) - Para networking

---

⭐ Si este proyecto te ayuda, por favor dale una estrella en GitHub! 
