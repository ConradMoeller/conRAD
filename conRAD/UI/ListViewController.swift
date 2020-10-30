//
//  ListViewController.swift
//  conRAD
//
//  Created by Conrad Moeller on 27.10.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import UIKit

protocol ListViewDelegate {
    
    func getFileList() -> [(id: String, name: String)]
    func setSelectedFile(id: String)
    func removeFile(id: String)
}

class ListViewNavigation: UINavigationController {

    var listView: ListViewController!
    
    convenience init() {
        let d = ListViewController()
        self.init(rootViewController: d)
        self.listView = d
    }
}

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    public var listViewDelegate: ListViewDelegate!
    
    var barItemTitle = NSLocalizedString("Cancel", comment: "no comment")
    var foundFileIds: [String] = []
    var foundFileNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissButton = UIBarButtonItem(title: barItemTitle, style: .plain, target: self, action: #selector(DeviceViewController.dismiss(button:)))
        self.navigationItem.rightBarButtonItem = dismissButton
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        foundFileIds.removeAll()
        foundFileNames.removeAll()
        tableView.reloadData()
        if listViewDelegate != nil {
            let files = listViewDelegate.getFileList()
            for file in files {
                addFile(id: file.id, name: file.name)
            }
        }
    }
    
    @objc func dismiss(button: UIBarButtonItem = UIBarButtonItem()) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addFile(id: String, name: String) {
        foundFileIds.append(id)
        foundFileNames.append(name)
        let indexPath = IndexPath(row: foundFileNames.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }


}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundFileNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DeviceCell"
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell
        }
        cell.textLabel?.text = foundFileNames[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if listViewDelegate != nil {
            listViewDelegate.setSelectedFile(id: foundFileIds[indexPath.row])
        }
        dismiss()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listViewDelegate.removeFile(id: foundFileIds[indexPath.row])
            foundFileIds.remove(at: indexPath.row)
            foundFileNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
