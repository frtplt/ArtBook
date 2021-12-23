//
//  DetailsVC.swift
//  ArtBook
//
//  Created by Firat on 22.12.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButtonn: UIButton!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var artistName: UITextField!
    @IBOutlet weak var artName: UITextField!
    @IBOutlet weak var artImage: UIImageView!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if chosenPainting != "" {
            
            saveButtonn.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            artName.text = name
                        }
                        if let artistNamee = result.value(forKey: "artist") as? String{
                            artistName.text = artistNamee
                        }
                        if let yearr = result.value(forKey: "year") as? Int{
                            year.text = String(yearr)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            artImage.image = image
                        }
                     
                }
            }
            }catch{
                print("error")
            }
        }else {
            saveButtonn.isHidden = false
            saveButtonn.isEnabled = false
            artName.text = ""
            artistName.text = ""
            year.text = ""
        }
        
        // Recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        artImage.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        artImage.addGestureRecognizer(imageTapRecognizer)
    }
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        artImage.image = info[.originalImage] as? UIImage
        saveButtonn.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    @IBAction func saveButton(_ sender: UIButton) {
        if artName.text == "" {
            
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(artName.text!, forKey: "name")
        newPainting.setValue(artName.text!, forKey: "artist")
        
        if let year = Int(year.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = artImage.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        do{
            try context.save()
            print("success")
        } catch{
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

