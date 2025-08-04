//
//  MetricsViewController.swift
//  NewRelic
//
//  Created by newrelic on 8/16/20.
//  Copyright © 2020 newrelic. All rights reserved.
//

import Foundation
import UIKit

struct MetricsAttribute {
    let label: String
    let value: String
}

class MetricsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var metrics: [(endpoint: String, averageTime: TimeInterval)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Metrics"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
tableView.separatorStyle = .none
        tableView.bounces = false
        
        // Load metrics data
        loadMetrics()
    }
    
    func loadMetrics() {
        metrics = NetworkMonitor.shared.getAllMetrics()
        tableView.reloadData()
    }
    
    func getDeviceInfo() -> (make: String, model: String, osVersion: String) {
        let device = UIDevice.current
        let make = "Apple"
        let model = device.model
        let osVersion = device.systemName + " " + device.systemVersion
        return (make: make, model: model, osVersion: osVersion)
    }
}

extension MetricsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // API metrics + device info (make/model + OS version)
        return metrics.count + 2
    }
    
func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricsCell", for: indexPath) as? MetricsTableViewCell
        
        let attribute: MetricsAttribute
        let deviceInfo = getDeviceInfo()
        
        if indexPath.row < metrics.count {
            // API metrics
            let metric = metrics[indexPath.row]
            let avgTimeMs = metric.averageTime * 1000 // Convert to milliseconds
            // Clean up endpoint name for display
            let displayEndpoint = metric.endpoint.hasPrefix("/breeds") ? "Cat Breeds API" : metric.endpoint
            attribute = MetricsAttribute(label: displayEndpoint, value: String(format: "%.2f ms", avgTimeMs))
        } else if indexPath.row == metrics.count {
            // Device make/model
            attribute = MetricsAttribute(label: "Device", value: "\(deviceInfo.make) \(deviceInfo.model)")
        } else {
            // OS version
            attribute = MetricsAttribute(label: "OS Version", value: deviceInfo.osVersion)
        }
        
        cell?.configure(attribute)
        return cell!
    }
}
