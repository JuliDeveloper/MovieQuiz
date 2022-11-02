//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 02.11.2022.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
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

        viewController?.showAnswerResult(isCorrect: isCorrectAnswer)
        viewController?.toggleStateButton(false)
    }

    private func saveStateUserAnswer(userChoice: Bool) -> QuizResultResponseViewModel {
        QuizResultResponseViewModel(isCorrect: userChoice)
    }
}
