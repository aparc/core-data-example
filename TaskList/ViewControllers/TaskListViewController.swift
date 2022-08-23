//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 21.08.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    // MARK: - Private Properties
    private let cellID = "task"
    private var taskList: [Task] = []

    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }

    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task") { [unowned self] taskName in
            save(taskName)
        }
    }
    
    private func fetchData() {
        StorageManager.shared.fetch(of: Task.self) { [unowned self] result in
            taskList = result
        }
    }
    
    private func save(_ taskName: String) {
        let task = StorageManager.shared.objectInContext(of: Task.self)
        task.title = taskName
        
        StorageManager.shared.saveContext { [unowned self] in
            taskList.append(task)
            let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [cellIndex], with: .automatic)
        }
    }
    
    private func update(task: Task, title: String) {
        task.title = title
        StorageManager.shared.saveContext()
    }
    
    private func delete(at index: Int) {
        let detachedTask = taskList.remove(at: index)
        StorageManager.shared.delete(detachedTask)
    }
    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
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
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        
        showAlert(withTitle: "Update Task", for: task) { [unowned self] taskName in
            update(task: task, title: taskName)
            tableView.reloadRows(at: [indexPath] , with: .automatic)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UIAlertController
extension TaskListViewController {
    
    private func showAlert(withTitle title: String, for task: Task? = nil, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: "What do you want to do?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            completion(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = task?.title
            textField.placeholder = "Enter task name"
        }
        
        present(alert, animated: true)
    }
    
}
