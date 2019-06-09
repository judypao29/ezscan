//
//  ViewController.swift
//  ezscan
//
//  Created by Judy Pao on 6/8/19.
//

import UIKit
import CoreData

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var addCardButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dataArray = [String]()

    override func viewDidAppear(_ animated: Bool)
    {
        dataArray = [String]()
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        request.returnsObjectsAsFaults = false
        do
        {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject]
            {
                dataArray.append(data.value(forKey: "name") as! String)
//                let imgData = data as! Image
//                dataArray.append(imgData.value(forKey: "name") as! String)
            }
        }
        catch
        {
            print("Failed")
        }
        
        myTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cardViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cardViewCell", for: indexPath) as! CardTableViewCell
        
        cell.backgroundColor = UIColor.yellow
        cell.cardName.text = dataArray.value(forKey: "name") as? String
        
        return cell
        
//        let cell = myTableView.dequeueReusableCell(withIdentifier: "cardViewCell", for: indexPath) as! CardTableViewCell
//        cell.cardName.text = dataArray[indexPath.item]
//        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

