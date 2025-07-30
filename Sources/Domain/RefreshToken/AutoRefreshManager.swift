//
//  AutoRefreshManager.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - AutoRefreshManager

/**
 * Gestor de renovación automática de tokens.
 */
@MainActor
public class AutoRefreshManager: Sendable {
    
    // MARK: - Properties
    
    private let refreshUseCase: RefreshTokenUseCase
    private let logger: AuthLoggerProtocol
    private let refreshInterval: TimeInterval
    private var refreshTimer: Timer?
    private var isRefreshing = false
    
    // MARK: - Initialization
    
    /**
     * Inicializa el gestor de renovación automática.
     *
     * - Parameters:
     *   - refreshUseCase: Caso de uso de renovación
     *   - logger: Logger para trazabilidad
     *   - refreshInterval: Intervalo de verificación en segundos (default: 5 minutos)
     */
    public init(
        refreshUseCase: RefreshTokenUseCase,
        logger: AuthLoggerProtocol,
        refreshInterval: TimeInterval = 5 * 60
    ) {
        self.refreshUseCase = refreshUseCase
        self.logger = logger
        self.refreshInterval = refreshInterval
    }
    
    // MARK: - Public Methods
    
    /**
     * Inicia la renovación automática de tokens.
     */
    public func startAutoRefresh() {
        stopAutoRefresh()
        
        logger.log(.info, "Iniciando renovación automática de tokens")
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            Task { @MainActor in
                await self.checkAndRefreshToken()
            }
        }
    }
    
    /**
     * Detiene la renovación automática de tokens.
     */
    public func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        logger.log(.info, "Detenida renovación automática de tokens")
    }
    
    /**
     * Fuerza una verificación y renovación inmediata.
     */
    public func forceCheckAndRefresh() async {
        logger.log(.info, "Forzar verificación y renovación")
        await checkAndRefreshToken()
    }
    
    // MARK: - Private Methods
    
    /**
     * Verifica si es necesario renovar el token y lo renueva si es necesario.
     */
    @MainActor
    private func checkAndRefreshToken() async {
        logger.log(.info, "Verificación y renovación")
        guard !isRefreshing else {
            logger.log(.debug, "Renovación ya en progreso, saltando verificación")
            return
        }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            if let _ = try await refreshUseCase.execute() {
                logger.log(.info, "Token renovado automáticamente")
            } else {
                logger.log(.debug, "Renovación automática no necesaria")
            }
        } catch {
            logger.log(.error, "Error en renovación automática: \(error.localizedDescription)")
        }
    }
}
