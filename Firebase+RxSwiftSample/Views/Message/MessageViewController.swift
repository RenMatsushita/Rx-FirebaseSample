//
//  ViewController.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

final class MessageViewController: UIViewController {
    
    @IBOutlet private weak var messageTableView: UITableView!
    
    @IBOutlet private weak var stackViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    private let dataSource: MessageTableViewDataSource = MessageTableViewDataSource()
    
    private let disposeBag: DisposeBag = DisposeBag()
    private lazy var viewModel: MessageViewModel = MessageViewModel(
        messageText: self.messageTextField.rx.text.asObservable(),
        sendButtonTapped: self.sendButton.rx.tap.asObservable()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        viewModel.messages
            .drive(messageTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        dataSource.rowCount
            .bind(to: scrollToBottom)
            .disposed(by: disposeBag)
        
        viewModel.showSignupViewController
            .bind(to: showSignupViewController)
            .disposed(by: disposeBag)
        
        viewModel.canSendMessage
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.sendSuccessed
            .bind(to: sendSuccessed)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .bind(to: showErrorMessage)
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                self.stackViewBottom.constant = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
    }
    
    func configureTableView() {
        messageTableView.tableFooterView = UIView(frame: .zero)
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "messageCell")
    }
    
    private var scrollToBottom: Binder<Int> {
        return Binder(self) { me, rowCount in
            DispatchQueue.main.async {
                if rowCount == -1 { return }
                self.messageTableView.scrollToRow(at: IndexPath(row: rowCount < 0 ? 0 : rowCount, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    private var sendSuccessed: Binder<Void> {
        return Binder(self) { me, _ in
            DispatchQueue.main.async {
                self.messageTextField.text = ""
            }
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

    private var showSignupViewController: Binder<Void> {
        return Binder(self) { me, _ in
            DispatchQueue.main.async {
                let signupViewController = UIStoryboard(name: "Signup", bundle: nil).instantiateViewController(withIdentifier: "Signup")
                me.present(signupViewController, animated: true, completion: nil)
            }
        }
    }
}
