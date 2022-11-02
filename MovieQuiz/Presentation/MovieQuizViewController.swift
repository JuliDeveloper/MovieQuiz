import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var questionTextLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var incorrectButton: UIButton!
    @IBOutlet private weak var correctButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
        
    private var presenter: MovieQuizPresenter?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = 20
        
        showLoadingIndicator()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - Actions
    
    @IBAction func yesButtonClicked() {
        presenter?.yesButtonClicked(correctButton)
    }
    
    @IBAction func noButtonClicked() {
        presenter?.noButtonClicked(incorrectButton)
    }
    
    // MARK: - Private functions
    func show(quiz step: QuizStepViewModel) {
        posterImageView.image = step.image
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
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
        presenter?.restartGame()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        presenter?.didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter?.showNextQuestionOrResults()
            self.posterImageView.layer.borderWidth = 0
            self.toggleStateButton(true)
        }
    }
    
    func toggleStateButton(_ state: Bool) {
        incorrectButton.isEnabled = state
        correctButton.isEnabled = state
    }
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            guard let statisticService = statisticService else { return }
//            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
//            
//            let message = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n" +
//            "Количество сыгранных квизов: \(statisticService.gamesCount )\n" +
//            "Рекорд: \(statisticService.bestGame.correct )/\(presenter.questionsAmount) (\(statisticService.bestGame.date.dateTimeString ))\n" +
//            "Cредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy ))%"
//            
//            let viewModel = QuizResultsViewModel(
//                title: "Этот раунд окончен!",
//                text: "\(message)",
//                buttonText: "Сыграть еще раз")
//            show(quiz: viewModel)
//        } else {
//            presenter.switchToNextQuestion()
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        toggleStateButton(false)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        toggleStateButton(true)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter?.create(model: AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.showLoadingIndicator()
                self.presenter?.questionFactory?.loadData()
            })
        )
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter?.didReceiveNextQuestion(question: question)
    }
    
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
    
    // MARK: - AlertPresenterDelegate
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
