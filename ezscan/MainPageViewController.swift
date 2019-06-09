//
//  ViewController.swift
//  ezscan
//
//  Created by Judy Pao on 6/8/19.
//

import UIKit
import CoreData

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var addCardButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let imagesInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.tableview.reloadData()
//    }
    
    override func viewDidLoad() {
        self.tableview.reloadData()
        let context = appDelegate.persistentContainer.viewContext
        imagesInfo.returnsObjectsAsFaults = false
        do {
            try context.fetch(imagesInfo)
        } catch {
            print("Failed")
        }
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = imagesInfo as? UITableViewDataSource
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardViewCell", for: indexPath) as! CardTableViewCell
        
        cell.backgroundColor = UIColor.yellow
        cell.cardName.text = imagesInfo.value(forKey: "name") as? String
        cell.cardImage.image = imagesInfo.value(forKey: "image") as? UIImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

