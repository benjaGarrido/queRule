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

class AddGameViewController: UIViewController {

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

        
    }

}
