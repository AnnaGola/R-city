//
//  Model.swift
//  R • city
//
//  Created by anna on 07.06.2022.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var shortDescription: String?
    @objc dynamic var imageData: Data?
    
    convenience init(name: String, location: String?, shortDescription: String?, imageData: Data?) {
    self.init()
    self.name = name
    self.location = location
    self.shortDescription = shortDescription
    self.imageData = imageData
  }
}
