//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 02.10.2022.
//

import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    
    func create(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        alert.view.accessibilityIdentifier = "Results"
        alert.addAction(action)
        delegate?.show(alert: alert)
    }
}
