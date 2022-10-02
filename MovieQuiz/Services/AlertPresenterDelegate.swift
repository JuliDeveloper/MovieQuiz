//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Julia Romanenko on 02.10.2022.
//

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func show(alert: UIAlertController)
}
