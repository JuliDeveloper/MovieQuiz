//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 04.10.2022.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func comparisonRecords(_ bestGame: GameRecord, _ currentGame: GameRecord) -> Bool {
        currentGame.correct > bestGame.correct
    }
}
