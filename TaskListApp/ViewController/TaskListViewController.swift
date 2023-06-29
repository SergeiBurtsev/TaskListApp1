//
//  ViewController.swift
//  TaskListApp
//
//  Created by Vasichko Anna on 29.06.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private let storageManager = StorageManager.shared
    
    private let cellID = "cell"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        storageManager.fetchData(to: &taskList)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        storageManager.delete(object: taskList[indexPath.row])
        taskList.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(withTitle: "Change Task", andMessage: "Set new title for your task")
    }
    
    //MARK: - Private methods
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if title == "New Task" {
            let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                save(task)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
            present(alert, animated: true)
        } else {
            let updateAction = UIAlertAction(title: "Update Task", style: .default) { [unowned self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                update(task: task)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { [unowned self] _ in
                guard let indexPath = tableView.indexPathForSelectedRow else { return }
                tableView.deselectRow(at: indexPath, animated: true)
            }
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "Update Task"
            }
            present(alert, animated: true)
        }
    }
    
    private func save(_ taskName: String) {
        storageManager.save(task: taskName, to: &taskList)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        dismiss(animated: true)
    }
    
    private func update(task taskName: String) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        taskList[indexPath.row].title = taskName
        tableView.reloadData()
        storageManager.saveContext()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SetupUI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MainBlue")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}
