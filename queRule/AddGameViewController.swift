//
//  AddGameViewController.swift
//  queRule
//
//  Created by Benjamín Garrido Barreiro on 7/1/17.
//  Copyright © 2017 Benjamín Garrido Barreiro. All rights reserved.
//

import UIKit
import CoreData

protocol AddGameViewControllerDelegate {
    func didAddGame()
}

class AddGameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var borrrowedSwitch: UISwitch!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtBorrowedTo: UITextField!
    @IBOutlet weak var txtBorrowedDate: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    var manageObjectContext: NSManagedObjectContext? = nil
    var imagePickerController = UIImagePickerController()
    var cameraPermissions: Bool = false
    var delegate: AddGameViewControllerDelegate?
    var game: Game? = nil
    var datePicker: UIDatePicker!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        /* Keyboard */
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.view.addGestureRecognizer(tapGesture)
        
        let takePictureGesture = UITapGestureRecognizer(target: self, action: #selector(takePictureTapped))
        self.gameImageView.addGestureRecognizer(takePictureGesture)
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        datePicker = UIDatePicker(frame: CGRect(x: 0, y: 210, width: 320, height: 216))
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerChangedValue), for: .valueChanged)
        txtBorrowedDate.inputView = datePicker
        
        if game == nil {
            // Estamos creando un nuevo juego
            self.title = "Añadir juego"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
            
            self.btnDelete.isHidden = true
            borrrowedSwitch.isOn = false
        } else {
            // Estamos modificando un juego
            self.title = "Detalles"
            self.txtTitle.text = game?.title
            if let borrowed = game?.borrowed {
                self.borrrowedSwitch.isOn = borrowed
            }
            
            self.txtBorrowedTo.text = game?.borrowedTo
            if let borrowedDate = game?.borrowedDate as? Date {
                self.txtBorrowedDate.text = dateFormatter.string(from: borrowedDate)
            }
            
            if let imageData = game?.image as? Data {
                self.gameImageView.image = UIImage(data: imageData)
            }
            
            self.btnDelete.isHidden = false
        }
        
        if !borrrowedSwitch.isOn {
            txtBorrowedTo.isEnabled = false
            txtBorrowedDate.isEnabled = false
        }
    }

    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: keyboardTime) { 
            self.view.frame.origin.y = -(keyboardFrame.height)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardTime = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        UIView.animate(withDuration: keyboardTime) {
            self.view.frame.origin.y = 0
        }
    }
        
    func viewTapped() {
        for view in self.view.subviews {
            if let textfield = view as? UITextField {
                textfield.resignFirstResponder()
            }
        }
    }
        
    func takePictureTapped() {
        guard cameraPermissions else {
            let permissionsAlertController = UIAlertController(title: "Permisos", message: "No tiene permisos para acceder a la cámara del dispositivo. Puede cambiar esta información en Ajustes", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            permissionsAlertController.addAction(okAction)
            present(permissionsAlertController, animated: true, completion: nil)
            
            return
        }
        
        let alertController = UIAlertController(title: "Añadir fotos del videojuego", message: "", preferredStyle: .actionSheet)
        
        let cameraOption = UIAlertAction(title: "Cámara", style: .default) { (alertAction) in
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        
        let cameraRollOption = UIAlertAction(title: "Carrete", style: .default) { (alertAction) in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        
        let cancelOption = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            alertController.addAction(cameraOption)
        }
        alertController.addAction(cameraRollOption)
        alertController.addAction(cancelOption)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func datePickerChangedValue(picker: UIDatePicker) {
        txtBorrowedDate.text = dateFormatter.string(from: picker.date)
    }
    
    func saveButtonPressed() {
        saveGame()
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
