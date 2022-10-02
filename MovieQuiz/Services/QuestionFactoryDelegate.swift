//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 02.10.2022.
//

import Foundation

protocol QuestionFactoryDelegate: class {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
