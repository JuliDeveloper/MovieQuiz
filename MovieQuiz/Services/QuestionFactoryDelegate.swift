//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 02.10.2022.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
