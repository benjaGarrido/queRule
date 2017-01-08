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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
