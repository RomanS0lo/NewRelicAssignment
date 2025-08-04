//
//  CatDetailsViewController.swift
//  NewRelic
//
//  Created by newrelic on 8/16/20.
//  Copyright © 2020 newrelic. All rights reserved.
//

import Foundation

import UIKit

struct CatAttribute {
    let label: String
    let value: String
}
class CatDetailsViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    var catDetail: CatDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
tableView.separatorStyle = .none
        tableView.bounces = false
        
        // Set title to cat breed
        self.title = catDetail?.breed ?? "Cat Details"
    }
}

extension CatDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // breed, country, origin, coat, pattern => 5
        return 5
    }
func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatDetailCell", for: indexPath) as? CatDetailTableViewCell
        
        guard let catDetail = catDetail else {
            return UITableViewCell()
        }
        
        let attribute: CatAttribute
        switch indexPath.row {
        case 0:
            attribute = CatAttribute(label: "Breed", value: catDetail.breed)
        case 1:
            attribute = CatAttribute(label: "Country", value: catDetail.country)
        case 2:
            attribute = CatAttribute(label: "Origin", value: catDetail.origin)
        case 3:
            attribute = CatAttribute(label: "Coat", value: catDetail.coat)
        case 4:
            attribute = CatAttribute(label: "Pattern", value: catDetail.pattern)
        default:
            attribute = CatAttribute(label: "", value: "")
        }
        
        cell?.configure(attribute)
        cell?.selectionStyle = .none
        return cell!
    }
}
