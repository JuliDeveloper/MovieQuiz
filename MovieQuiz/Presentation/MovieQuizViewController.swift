import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var incorrectButton: UIButton!
    @IBOutlet private weak var correctButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = 20
        
        if let firstQuestion = questionFactory.requestNextQuestion() {
            self.currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkResponse(sender, userChoice: true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkResponse(sender, userChoice: false)
    }
    
    private func checkResponse(_ button: UIButton, userChoice: Bool) {
        guard let currentQuestion = currentQuestion else { return }

        
        let responseStateModel = saveStateUserAnswer(userChoice: userChoice)
        let isCorrectAnswer = responseStateModel.isCorrect == currentQuestion.correctAnswer
        
        showAnswerResult(isCorrect: isCorrectAnswer)
        toggleStateButton(false)
    }
    
    private func saveStateUserAnswer(userChoice: Bool) -> QuizResultResponseViewModel {
        QuizResultResponseViewModel(isCorrect: userChoice)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        guard let currentQuestion = currentQuestion else { return }

        posterImageView.image = UIImage(named: currentQuestion.image)
        questionTextLabel.text = "\(currentQuestion.text)"
        counterLabel.text = "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.restartQuiz()
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        if let firstQuestion = self.questionFactory.requestNextQuestion() {
            self.currentQuestion = firstQuestion
            let viewModel = self.convert(model: firstQuestion)
            
            self.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.posterImageView.layer.borderWidth = 0
            self.toggleStateButton(true)
        }
    }
    
    private func toggleStateButton(_ state: Bool) {
        incorrectButton.isEnabled = state
        correctButton.isEnabled = state
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                        "Поздравляем, Вы ответили на 10 из 10!" :
                        "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен! ",
                text: "\(text)",
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                
                show(quiz: viewModel)
            }
        }
    }
}
