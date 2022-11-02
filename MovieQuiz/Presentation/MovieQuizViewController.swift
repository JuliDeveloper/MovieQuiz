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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = 20
        showLoadingIndicator()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - Actions
    @IBAction func yesButtonClicked() {
        presenter?.yesButtonClicked(correctButton)
    }
    
    @IBAction func noButtonClicked() {
        presenter?.noButtonClicked(incorrectButton)
    }
    
    // MARK: - Functions
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
    
    func highlightImageBorder(isCorrect: Bool) {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.borderWidth = 8
        posterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.posterImageView.layer.borderWidth = 0

        }
    }
    
    func toggleStateButton(_ state: Bool) {
        incorrectButton.isEnabled = state
        correctButton.isEnabled = state
    }
    
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
    
    private func restartQuiz() {
        presenter?.restartGame()
    }
    
    // MARK: - AlertPresenterDelegate
    func show(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
