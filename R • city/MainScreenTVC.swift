//
//  MainScreenTVC.swift
//  R • city
//
//  Created by anna on 07.06.2022.
//

import UIKit

class MainScreenTVC: UITableViewController {

    var favoritePlaces = ["Подвесные качели у реки Каменка"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePlaces.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = favoritePlaces[indexPath.row] //здесь я нулевому индексу строки добавляю значение нулевого индекса массиваб чтобы текст этой строки стал собержимым массива по нулевому индексу
        return cell
    }
 
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
