//
//  FilesViewController.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/26.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import UIKit

class FilesViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Pull down and reload
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        tableView.refreshControl = refresh

        DispatchQueue.global(qos: .default).async {
            self.reload()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private func reload() {
        if let resURL = Bundle.main.resourceURL {
            if let urls = try? FileManager.default.contentsOfDirectory(at: resURL, includingPropertiesForKeys: nil) {
                self.resFiles = urls.filter { url in url.pathExtension == "nes" }
            }
        }
        if let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("\(docURL)")
            if let urls = try? FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: nil) {
                self.docFiles = urls.filter { url in url.pathExtension == "nes" }
            }
        }
    }

    @objc func refreshAction(_ sender: UIRefreshControl) {
        DispatchQueue.global(qos: .background).async {
            self.reload()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }

    enum Section: Int, CaseIterable {
        case res, doc
    }

    var resFiles: [URL]? = nil
    var docFiles: [URL]? = nil

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        guard let section = Section(rawValue: numberOfRowsInSection) else {
            return 0
        }
        switch section {
        case .res:
            return resFiles?.count ?? 0
        case .doc:
            return docFiles?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entry", for: indexPath)
        guard let section = Section(rawValue: indexPath.section) else {
            return cell
        }
        switch section {
        case .res:
            let url = resFiles?[indexPath.row]
            cell.textLabel?.text = url?.lastPathComponent
        case .doc:
            let url = docFiles?[indexPath.row]
            cell.textLabel?.text = url?.lastPathComponent
        }
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emulator" {
            guard let vc = segue.destination as? EmuViewController else {
                return
            }
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            guard let section = Section(rawValue: indexPath.section) else {
                return
            }
            switch section {
            case .res:
                vc.url = resFiles?[indexPath.row]
            case .doc:
                vc.url = docFiles?[indexPath.row]
            }
        }
    }
}
