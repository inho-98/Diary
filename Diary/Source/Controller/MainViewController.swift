//
//  Diary - MainViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreData

final class MainViewController: UIViewController {
    // MARK: - Properties
    
    private let mainDiaryView = MainDiaryView()
    private var diaries: [Diary] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = mainDiaryView
        configureNavigationItem()
        setUpTableView()
        decodeDiaryData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let entity = readCoreData() {
            diaries = convertToDiary(from: entity)
            mainDiaryView.diaryTableView.reloadData()
        }
    }
    
    // MARK: - Private Methods
    
    private func configureNavigationItem() {
        navigationItem.title = NameSpace.navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addDiary)
        )
    }
    
    private func setUpTableView() {
        mainDiaryView.diaryTableView.dataSource = self
    }
    
    private func decodeDiaryData() {
        guard let dataAsset = NSDataAsset(name: NameSpace.assetName) else { return }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            diaries = try decoder.decode([Diary].self, from: dataAsset.data)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func convertToDiary(from entityArray: [Entity]) -> [Diary] {
        var diaryArray: [Diary] = []
        
        entityArray.forEach { entity in
            guard let title = entity.title,
                  let body = entity.body,
                  let createdDate = entity.createdDate,
                  let createdAt = Int(createdDate) else { return }
            let diary = Diary.init(title: title, body: body, createdAt: createdAt)
            
            diaryArray.append(diary)
        }
        
        return diaryArray
    }
    
    // MARK: - Action Methods

    @objc private func addDiary() {
        navigationController?.pushViewController(DiaryFormViewController(), animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: CustomDiaryCell = tableView.dequeueReusableCell(
            withIdentifier: CustomDiaryCell.identifier,
            for: indexPath
        ) as? CustomDiaryCell else {
            return UITableViewCell()
        }
        
        let diary = diaries[indexPath.row]
        
        cell.configureCell(with: diary)
        
        return cell
    }
}

// MARK: - CoreData Methods

extension MainViewController {
    func readCoreData() -> [Entity]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Entity>(entityName: "Entity")
        let result = try? managedContext.fetch(fetchRequest)
        
        return result
    }
}

// MARK: - NameSpace

private enum NameSpace {
    static let navigationTitle = "일기장"
    static let assetName = "sample"
}
