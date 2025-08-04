//
//  NetworkReachability.swift
//  NewRelic
//
//  Created on 8/4/25.
//  Copyright © 2025. All rights reserved.
//

import Foundation
import Network

class NetworkReachability {
    static let shared = NetworkReachability()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.newrelic.network")
    
    private(set) var isConnected: Bool = true
    private(set) var connectionType: NWInterface.InterfaceType?
    
    var connectionStatusChanged: ((Bool) -> Void)?
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            
            if path.usesInterfaceType(.wifi) {
                self?.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self?.connectionType = .cellular
            } else {
                self?.connectionType = nil
            }
            
            DispatchQueue.main.async {
                self?.connectionStatusChanged?(self?.isConnected ?? false)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
