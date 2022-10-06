//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 04.10.2022.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    var correctAnswersCount: Int {
        get {
            StorageManager.shared.loadInfo(
                for: Keys.correct.rawValue,
                and: Int.self
            ) ?? 0
        }
        set {
            StorageManager.shared.saveNewInfo(
                for: Keys.correct.rawValue,
                from: newValue
            )
        }
    }
    
    var totalAccuracy: Double {
        get {
            StorageManager.shared.loadInfo(
                for: Keys.total.rawValue,
                and: Double.self
            ) ?? 0.0
        }
        set {
            StorageManager.shared.saveNewInfo(
                for: Keys.total.rawValue,
                from: newValue
            )
        }
    }
    
    var gamesCount: Int {
        get {
            StorageManager.shared.loadInfo(
                for: Keys.gamesCount.rawValue,
                and: Int.self
            ) ?? 0
        }
        set {
            StorageManager.shared.saveNewInfo(
                for: Keys.gamesCount.rawValue,
                from: newValue
            )
        }
    }
    
    private(set) var bestGame: GameRecord {
        get {
            StorageManager.shared.loadInfo(
                for: Keys.bestGame.rawValue,
                and: GameRecord.self
            ) ?? GameRecord(correct: 0, total: 0, date: Date())
        }
        set {StorageManager.shared.saveNewInfo(
            for: Keys.bestGame.rawValue,
            from: newValue
        )
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswersCount += count
        
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        if GameRecord.comparisonRecords(bestGame, currentGame) {
            bestGame = currentGame
        }
        
        totalAccuracy = Double(correctAnswersCount) / Double(gamesCount) * 10.0
    }
}
