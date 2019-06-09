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
            for data in result as! [NSManagedObject]
            {
                let pic = data.value(forKey: "image") as! NSData
                dataArray.append(data.value(forKey: "name") as! String)
                imgArray.append(UIImage(data: pic as Data)!)
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
        return 90
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            dataArray.remove(at: indexPath.row)
            imgArray.remove(at: indexPath.row)
            myTableView.beginUpdates()
            myTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
            myTableView.endUpdates()
        }
    }
    
}

