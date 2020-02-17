//
//  MessageViewModel.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class MessageViewModel {
    
    private let messagesRelay = BehaviorRelay<[Message]>(value: [])
    var messages: Driver<[Message]> {
        return messagesRelay.asDriver()
    }
    
    let messagesOnUpdate: Observable<Void>
    
    let showSignupViewController: Observable<Void>
    let canSendMessage: Observable<Bool>
    let sendSuccessed = PublishSubject<Void>()
    let errorMessage = PublishSubject<String>()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(messageText: Observable<String?>, sendButtonTapped: Observable<Void>, model: MessageModelProtocol = MessageModel()) {
        
        messagesOnUpdate = messagesRelay
            .map { _ in }
        
        showSignupViewController = model.wasSignup()
            .filter { $0 == false }
            .map { _ in}
            
        canSendMessage = messageText
            .flatMap { messageText -> Observable<Bool> in
                guard let _messageText = messageText else { return .error(FirebaseErrors.emptyContent) }
                return .just(!_messageText.isEmpty)
            }
        
        model.fetchMessages()
            .subscribe(onNext: { [messagesRelay, sendSuccessed] messages in
                messagesRelay.accept(messages)
                sendSuccessed.onNext(())
            }, onError: { [errorMessage] error in
                if let _error = error as? FirebaseErrors {
                    errorMessage.onNext(_error.message)
                }
            })
            .disposed(by: disposeBag)
        
        let sendEvent = sendButtonTapped.withLatestFrom(messageText)
            .flatMap { messageText -> Observable<Void> in
                guard let _messageText = messageText else { return .error(FirebaseErrors.emptyContent) }
                return model.postMessage(messageText: _messageText).asObservable()
            }
        
        sendEvent
            .subscribe(onNext: { [sendSuccessed] _ in
                sendSuccessed.onNext(())
            },onError: { [errorMessage] error in
                if let _error = error as? FirebaseErrors {
                    errorMessage.onNext(_error.message)
                }
            })
            .disposed(by: disposeBag)
    }
}
