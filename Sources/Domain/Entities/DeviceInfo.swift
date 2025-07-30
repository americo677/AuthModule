//
//  DeviceInfo.swift
//  AuthModule
//
//  Created by Americo Jose Cantillo Gutierrez on 30/07/25.
//

import Foundation

/**
 * Información del dispositivo.
 */
public struct DeviceInfo {
    
    public let deviceId: String
    public let deviceModel: String
    public let osVersion: String
    public let appVersion: String
    public let platform: String
    
    public init(
        deviceId: String,
        deviceModel: String,
        osVersion: String,
        appVersion: String,
        platform: String = "iOS"
    ) {
        self.deviceId = deviceId
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.appVersion = appVersion
        self.platform = platform
    }
    
    /**
     * Convierte la información del dispositivo a diccionario.
     *
     * - Returns: Diccionario con la información
     */
    public func toDictionary() -> [String: String] {
        return [
            "device_id": deviceId,
            "device_model": deviceModel,
            "os_version": osVersion,
            "app_version": appVersion,
            "platform": platform
        ]
    }
}
