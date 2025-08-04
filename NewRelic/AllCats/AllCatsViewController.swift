//
//  AllCatsViewController.swift
//  NewRelic
//
//  Created by newrelic on 8/15/20.
//  Copyright © 2020 newrelic. All rights reserved.
//

import UIKit

class AllCatsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var cats: [CatDetail] = []
    var downloadState: DownloadState = .downloading
    var currentPage = 1
    var totalCats = 0
    var isLoadingPage = false
    let perPage = 30
    var loadingIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Metrics", style: .plain, target: self, action: #selector(self.rightButtonTapped(sender:)))
        
        // Setup loading indicator
        setupLoadingIndicator()
        
        // Setup pull-to-refresh
        setupRefreshControl()
        
        
        loadMoreCats()
    }
    
    @objc func rightButtonTapped(sender: UIBarButtonItem) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let metricsView = board.instantiateViewController(withIdentifier: "MetricsViewController")
        if let metricsView = metricsView as? MetricsViewController {
            navigationController?.pushViewController(metricsView, animated: true)
        }
        return
    }
    
    func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshData() {
        // Reset pagination and clear existing data
        cats.removeAll()
        currentPage = 1
        totalCats = 0
        
        // Reload data from the beginning
        loadMoreCats()
        
        // End refreshing will be called when loadMoreCats completes
    }
    
    func loadMoreCats() {
        guard !isLoadingPage else { return }
        
        isLoadingPage = true
        downloadState = .downloading
        
        // Show loading indicator for initial load
        if cats.isEmpty {
            loadingIndicator.startAnimating()
            tableView.isHidden = true
        }
        
        CatFetcher.shared.loadCats(perPage: perPage, page: currentPage, queue: .main) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadingPage = false
            self.downloadState = .done
            
            // Hide loading indicator
            self.loadingIndicator.stopAnimating()
            self.tableView.isHidden = false
            
            // End refresh control if it's active
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            switch result {
            case .success(let catResult):
                self.cats.append(contentsOf: catResult.data)
                self.totalCats = catResult.total
                self.currentPage += 1
                self.tableView.reloadData()
            case .failure(let error):
                self.showErrorAlert(for: error)
            }
        }
    }
    
    func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to load cats. Please check your internet connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadMoreCats()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func showErrorAlert(for error: CatFetchError) {
        let title = "Error"
        let message: String
        
        switch error {
        case .networkError:
            message = "Network error occurred. Please check your internet connection and try again."
        case .noData:
            message = "No data received from server. Please try again."
        case .decodingError:
            message = "Unable to process server response. Please try again."
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadMoreCats()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension AllCatsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cats.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath) as? CatTableViewCell

let cat = cats[indexPath.row]
        cell?.configure(name: cat.breed, state: indexPath.row < cats.count - 1 ? .done : downloadState)
        
        // Load more cats when reaching the end
        if indexPath.row == cats.count - 5 && cats.count < totalCats {
            loadMoreCats()
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let detailsView = board.instantiateViewController(withIdentifier: "CatDetailsViewController")
        if let detailsView = detailsView as? CatDetailsViewController {
            detailsView.catDetail = cats[indexPath.row]
            navigationController?.pushViewController(detailsView, animated: true)
        }
    }
}
