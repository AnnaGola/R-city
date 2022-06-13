//
//  NewPlaceTVC.swift
//  R • city
//
//  Created by anna on 07.06.2022.
//

import UIKit

class NewPlaceTVC: UITableViewController {
    
    var currentPlace: Place?
    var imageIsChanged = false
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeNameTF: UITextField!
    @IBOutlet weak var placeDescriptionTF: UITextField!
    @IBOutlet weak var placeLocationTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        placeLocationTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        placeNameTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setUpEditScreen()
    }
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera") //#imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo") //#imageLiteral(resourceName: "photo")
            
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
                
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            let identifier = segue.identifier,
            let mapVC = segue.destination as? MapVC
            else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showMap" {
        mapVC.place.name = placeNameTF.text!
        mapVC.place.location = placeLocationTF.text
        mapVC.place.shortDescription = placeDescriptionTF.text
        mapVC.place.imageData = placeImage.image?.pngData()
        // это то, что покажется на карте в виде пина с названием, описанием и картинкой по выбранному адресу
        }
    }
    
    // сохраняет новые и измененные данные вне зависимости от режима создания записи или ее редактирования
    func savePlace() {
        
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        let imageData = image?.pngData()
        let newPlace = Place(name: placeNameTF.text!,
                             location: placeLocationTF.text,
                             shortDescription: placeDescriptionTF.text,
                             imageData: imageData)
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.shortDescription = newPlace.shortDescription
                currentPlace?.imageData = newPlace.imageData
            }
        } else {
            Manager.saveObject(newPlace) // добавление новой записи в базе данных
        }
    }
    
    private func setUpEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            guard let data = currentPlace?.imageData,
                  let image = UIImage(data: data)
            else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeNameTF.text = currentPlace?.name
            placeLocationTF.text = currentPlace?.location
            placeDescriptionTF.text = currentPlace?.shortDescription
            // создание окна с редактированием уже существующих данных, с последующим их сохранением в этом же файле
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) //  кастомизация кнопки вовзрата
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - Text field delegate

extension NewPlaceTVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeLocationTF.text?.isEmpty == false && placeNameTF.text?.isEmpty == false {
           saveButton.isEnabled = true
        } else {
           saveButton.isEnabled = false
        }
    }
}

// MARK: - work with image

extension NewPlaceTVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
        
    }
}

extension NewPlaceTVC: MapViewControllerDelegare {
    func getAdderess(_ newAddress: String?) {
        placeLocationTF.text = newAddress
    }
}
