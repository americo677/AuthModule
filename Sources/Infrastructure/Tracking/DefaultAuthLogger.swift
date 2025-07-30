//
//  DefaultAuthLogger.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

// MARK: - DefaultAuthLogger

/**
 * Implementación por defecto del logger de autenticación.
 */
public class DefaultAuthLogger: AuthLoggerProtocol {
    
    private let enableConsoleLogging: Bool
    private let enableFileLogging: Bool
    private let logFilePath: String?
    
    public init(
        enableConsoleLogging: Bool = true,
        enableFileLogging: Bool = false,
        logFilePath: String? = nil
    ) {
        self.enableConsoleLogging = enableConsoleLogging
        self.enableFileLogging = enableFileLogging
        self.logFilePath = logFilePath
    }
    
    public func log(
        _ level: LogLevel,
        _ message: String,
        file: String? = nil,
        function: String? = nil,
        line: Int? = nil
    ) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fileInfo = file.map { " [\($0)" } ?? ""
        let functionInfo = function.map { ":\($0)" } ?? ""
        let lineInfo = line.map { ":\($0)]" } ?? ""
        let context = fileInfo + functionInfo + lineInfo
        
        let logMessage = "[\(timestamp)] [\(level.rawValue)]\(context) \(message)"
        
        if enableConsoleLogging {
            print(logMessage)
        }
        
        if enableFileLogging, let path = logFilePath {
            writeToFile(logMessage, path: path)
        }
    }
    
    public func log(_ level: LogLevel, _ message: String) {
        log(level, message, file: nil, function: nil, line: nil)
    }
    
    private func writeToFile(_ message: String, path: String) {
        guard let data = (message + "\n").data(using: .utf8) else { return }
        
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } else {
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }
}

