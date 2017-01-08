//
//  GamesViewController.swift
//  queRule
//
//  Created by Benjamín Garrido Barreiro on 7/1/17.
//  Copyright © 2017 Benjamín Garrido Barreiro. All rights reserved.
//

import UIKit
import CoreData

class GamesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterControl: UISegmentedControl!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var lstGames: [Game] = [Game]()
    
    @IBAction func filterChange(_ sender: UISegmentedControl){
        performGamesQuery()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Cuando se cargue la pantalla llamamos a la consulta
        performGamesQuery()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if lstGames.count == 0 {
            // Creamos un imageView
            let imageView = UIImageView(image: UIImage(named: "img_empty_screen"))
            imageView.contentMode = .center
            collectionView.backgroundView = imageView
        } else {
            collectionView.backgroundView = UIView()
        }
        return lstGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCell", for: indexPath) as! GameCollectionViewCell
    
        let game = lstGames[indexPath.row]
        
        cell.lblTitle.text = game.title
        
        var highlightColor = #colorLiteral(red: 0.9058823529, green: 0.2980392157, blue: 0.2352941176, alpha: 1)
        if !game.borrowed {
            highlightColor = #colorLiteral(red: 0.2039215686, green: 0.5960784314, blue: 0.8588235294, alpha: 1)
        }
        
        cell.lblBorrowed.attributedText = self.formatColours(string: "PRESTADO: \(game.borrowed ? "SI": "NO")", color: highlightColor)
        
        if let borrowedTo = game.borrowedTo {
            cell.lblBorrowedTo.attributedText = self.formatColours(string: "A: \(borrowedTo)", color: highlightColor)
        } else {
            cell.lblBorrowedTo.attributedText = self.formatColours(string: "A: --", color: highlightColor)
        }
        
        if let borrowedDate = game.borrowedDate as? Date{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            cell.lblBorrowedDate.attributedText = self.formatColours(string: "FECHA: \(dateFormatter.string(from: borrowedDate))", color: highlightColor)
        } else {
            cell.lblBorrowedDate.attributedText = self.formatColours(string: "FECHA: --", color: highlightColor)
        }
        
        if let image = game.image as? Data {
            cell.imageView.image = UIImage(data: image)
        }
        
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSize(width: 1, height: 1)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.2
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width - 20, height: 120)
    }
    
    // Cuando seleccionamos una celda para editar
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editGameSegue", sender: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Espcacio desde el borde superior hasta el punto que estamos tirando
        let offsetY = scrollView.contentOffset.y
        if (offsetY < -120) {
            // Lanzamos la modal
            performSegue(withIdentifier: "addGameSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGameSegue" {
            let addNavVC = segue.destination as! UINavigationController
            let addVC = addNavVC.topViewController as! AddGameViewController
            addVC.manageObjectContext = self.managedObjectContext
            
            addVC.delegate = self
        }
        if segue.identifier == "editGameSegue" {
            let addGameVC = segue.destination as! AddGameViewController
            addGameVC.manageObjectContext = self.managedObjectContext
            
            let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.row
            let game = lstGames[selectedIndex!]
            addGameVC.game = game
            
            addGameVC.delegate = self
        }
    }
    
    // Creamos un método que nos devuelva un texto con formato (enriquecido)
    func formatColours(string: String, color: UIColor) -> NSMutableAttributedString {
        let length = string.characters.count
        let colonPosition = string.indexOf(target: ":")!
        
        let myMutableString = NSMutableAttributedString(string: string, attributes: nil)
        
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: 0, length: length))
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: colonPosition + 1))
        
        return myMutableString
    }
    
    func performGamesQuery() {
        let request: NSFetchRequest<Game> = Game.fetchRequest()
        
        let sortByDate = NSSortDescriptor(key: "dateCreated", ascending: false)
        request.sortDescriptors = [sortByDate]
        
        if filterControl.selectedSegmentIndex == 0 {
            // Establecemos el predicado (clausula where)
            let predicate = NSPredicate(format: "borrowed = true")
            request.predicate = predicate
        }
        
        do {
            let fetchedGames = try managedObjectContext?.fetch(request)
            if let fetchedGames = fetchedGames {
                lstGames = fetchedGames
                // Recargamos la pantala
                collectionView.reloadData()
            }
        } catch {
            print("Error recuperando datos de CoreData")
        }
    }
}

extension GamesViewController: AddGameViewControllerDelegate {
    func didAddGame() {
        self.collectionView.reloadData()
    }
}

// Creamos una extension sobre la clase string
extension String {
    func indexOf(target: String) -> Int? {
        if let range = self.range(of: target) {
            return distance(from: self.startIndex, to: range.lowerBound)
        }
        return nil
    }
}
