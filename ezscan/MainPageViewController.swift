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
    var imgArray = [UIImage]()
    var selectedImage: UIImage?

    override func viewDidAppear(_ animated: Bool)
    {
        dataArray = [String]()
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        request.returnsObjectsAsFaults = false
        do
        {
            let result = try context.fetch(request)
           // let match = results[i] as! NSManagedObject
            for data in result as! [NSManagedObject]
            {
                dataArray.append(data.value(forKey: "name") as! String)
                let pic = data.value(forKey: "image") as! NSData
                imgArray.append(UIImage(data: pic as Data)!)
              //  imgArray.append(data.value(forKey: "image") as! UIImage)
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
        addCardButton.layer.cornerRadius = 5
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cardViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTableView.dequeueReusableCell(withIdentifier: "cardViewCell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.item]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "displayBarcode", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "displayBarcode",
            let destination = segue.destination as? BarcodeViewController,
            let selectedIndex = myTableView.indexPathForSelectedRow?.row
        {
            destination.name = dataArray[selectedIndex]
            destination.image = imgArray[selectedIndex]
        }
    }
    
}

