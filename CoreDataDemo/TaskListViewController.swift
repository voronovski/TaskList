//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 29.09.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
    }

    // MARK: - Navigation Bar setting up
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: - Private methods
    @objc private func addNewTask() {
        showAlert()
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try StorageManager.shared.context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch data", error)
        }
    }
}

// MARK: - Table View Lifecycle
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedTask = taskList.remove(at: indexPath.row)
            StorageManager.shared.delete(task: deletedTask)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = taskList[indexPath.row].name
        showAlert(text ?? "", indexPath.row)
    }
}
// MARK: - Alert Controller
extension TaskListViewController {
    private func showAlert(_ text: String = "", _ index: Int = 0) {
        if text != "" {
            let alert = UIAlertController(title: "Edit task", message: "Please, change the task", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let changes = alert.textFields?.first?.text, !changes.isEmpty else { return }
                self.edit(changes, index)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.text = text
            }
            
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "New Task", message: "What do you want to do?", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.save(task)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
            
            present(alert, animated: true)
        }
        
    }
    
    private func save(_ taskName: String) {
        let task = Task(context: StorageManager.shared.context)
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        do {
            try StorageManager.shared.context.save()
        } catch {
            print(error)
        }
    }
    
    private func edit(_ changes: String, _ index: Int) {
        let task = taskList[index]
        task.name = changes

        do {
            try StorageManager.shared.context.save()
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
}
