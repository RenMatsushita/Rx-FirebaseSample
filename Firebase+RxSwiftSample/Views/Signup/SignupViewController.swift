//
//  SignupViewController.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import Alertift

final class SignupViewController: UIViewController {
    
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    lazy var viewModel: SignupViewModel = SignupViewModel(
        name: self.nameTextField.rx.text.asObservable(),
        doneButtonTapped: self.doneButton.rx.tap.asObservable()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        imageView.rx.tapGesture()
            .skip(1)
            .map { _ in }
            .bind(to: showImagePickAlert)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.isError
            .bind(to: showErrorMessage)
            .disposed(by: disposeBag)
        
        viewModel.isSuccessed
            .bind(to: dismiss)
            .disposed(by: disposeBag)
    }
    
    private var showImagePickAlert: Binder<Void> {
        return Binder(self) { me, _ in
            Alertift.actionSheet()
                .action(.default("Camera"), handler: {
                    self.imagePicker(.camera)
                })
                .action(.default("PhotoLibrary"), handler: {
                    self.imagePicker(.photoLibrary)
                })
                .action(.cancel("Cancel"))
                .show(on: me, completion: nil)
        }
    }
    
    private var showErrorMessage: Binder<String> {
        return Binder(self) { me, message in
            let alertController = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
            let positiveAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(positiveAction)
            me.present(alertController, animated: true, completion: nil)
        }
    }
    
    private var dismiss: Binder<Void> {
        return Binder(self) { me, message in
            me.dismiss(animated: true, completion: nil)
        }
    }
    
    func configure() {
        print(imageView.frame)
        print(imageView.bounds)
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.layer.borderColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
    }
}
