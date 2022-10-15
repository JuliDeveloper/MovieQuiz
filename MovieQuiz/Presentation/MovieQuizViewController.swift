import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var incorrectButton: UIButton!
    @IBOutlet private weak var correctButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = 20
        
        showLoadingIndicator()
        
        questionFactory = QuestionFactory(moviesLoader:  MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkResponse(sender, userChoice: true)
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkResponse(sender, userChoice: false)
    }
    
    // MARK: - Private functions
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

        posterImageView.image = UIImage(data: currentQuestion.image)
        questionTextLabel.text = "\(currentQuestion.text)"
        counterLabel.text = "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        alertPresenter?.create(model: AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.restartQuiz()
            })
        )
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        
        questionFactory?.requestNextQuestion()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
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
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let message = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
            "Количество сыгранных квизов: \(statisticService.gamesCount )\n" +
            "Рекорд: \(statisticService.bestGame.correct )/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString ))\n" +
            "Cредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy ))%"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен! ",
                text: "\(message)",
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        toggleStateButton(false)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        toggleStateButton(true)
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter?.create(model: AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.showLoadingIndicator()
                self.questionFactory?.loadData()
            })
        )
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
