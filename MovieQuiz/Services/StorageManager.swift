//
//  StorageManager.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 06.10.2022.
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func saveNewInfo<T: Codable>(for key: String, from newValue: T) {
        guard let data = try? JSONEncoder().encode(newValue) else {
            print("Невозможно сохранить результат")
            return
        }
        userDefaults.set(data, forKey: key)
    }
    
    func loadInfo<T: Codable>(for key: String, and dataType: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key),
              let result = try? JSONDecoder().decode(dataType.self, from: data) else {
            return nil
        }
        return result
    }
}
