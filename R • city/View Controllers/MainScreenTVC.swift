//
//  MainScreenTVC.swift
//  R • city
//
//  Created by anna on 07.06.2022.
//

import UIKit
import RealmSwift
import MapKit

class MainScreenTVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var places: Results<Place>!
    

    @IBOutlet weak var mapWithAllPlaces: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeObserver()
        places = realm.objects(Place.self)
    }
    
    // MARK: - Table view data source
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTVC
        
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.descriptionLabel.text = place.shortDescription
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }

    // MARK: - Table view delegate
   
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
  
    func swipeObserver() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        let alert = UIAlertController(title: "Oops!", message: "this function is not available now, sorry", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, complition) in
            Manager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .fade)
            complition(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDitail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceTVC
            newPlaceVC.currentPlace = place
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
    
        guard let newPlaceVC = segue.source as? NewPlaceTVC else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func mapPressed(_ sender: UIBarButtonItem) {
        
    }
    
  
}
