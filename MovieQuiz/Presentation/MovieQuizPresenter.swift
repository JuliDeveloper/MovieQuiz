//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 02.11.2022.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0

    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Functions
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked(_ sender: UIButton) {
        checkResponse(sender, userChoice: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        checkResponse(sender, userChoice: false)
    }
    
    private func checkResponse(_ button: UIButton, userChoice: Bool) {
        guard let currentQuestion = currentQuestion else { return }

        let responseStateModel = saveStateUserAnswer(userChoice: userChoice)
        let isCorrectAnswer = responseStateModel.isCorrect == currentQuestion.correctAnswer

        proceedWithAnswer(isCorrect: isCorrectAnswer)
        viewController?.toggleStateButton(false)
    }

    private func saveStateUserAnswer(userChoice: Bool) -> QuizResultResponseViewModel {
        QuizResultResponseViewModel(isCorrect: userChoice)
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let message = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount )\n" +
            "Рекорд: \(statisticService.bestGame.correct )/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString ))\n" +
            "Cредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy ))%"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "\(message)",
                buttonText: "Сыграть еще раз")
                viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            self.viewController?.toggleStateButton(true)
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
