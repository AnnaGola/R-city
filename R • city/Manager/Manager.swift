//
//  Manager.swift
//  R • city
//
//  Created by anna on 07.06.2022.
//

import RealmSwift

let realm = try! Realm()

class Manager {
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place) // как сохранить объекты в приложении
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place) // как удалить объекты из приложения
        }
    }
}


