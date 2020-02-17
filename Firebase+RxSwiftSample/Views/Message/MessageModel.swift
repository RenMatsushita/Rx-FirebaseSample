//
//  MessageModel.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol MessageModelProtocol {
    func postMessage(messageText: String) -> Single<Void>
    func fetchMessages() -> Observable<[Message]>
    func wasSignup() -> Observable<Bool>
}

final class MessageModel: MessageModelProtocol {
    private let firestore = Firestore.firestore()
    
    func postMessage(messageText: String) -> Single<Void> {
        // - todo: 強制アンラップ
        guard let name = User.name else { return .error(FirebaseErrors.notSignup)}
        guard let imageName = User.imageName else { return .error(FirebaseErrors.notSignup)}
        
        let message: Message = Message(name: name, content: messageText, imageName: imageName)
        return Single.create(subscribe: { observer in
            do {
                _ = try self.firestore
                    .collection("Messages")
                    .addDocument(from: message, encoder: Firestore.Encoder(), completion: { error in
                        if let error = error {
                            observer(.error(FirebaseErrors.network))
                            print(error)
                            return
                        }
                        
                        observer(.success(()))
                    })
            } catch {
                observer(.error(FirebaseErrors.encodeError))
            }
            
            return Disposables.create()
        })
    }
    
    func fetchMessages() -> Observable<[Message]> {
        return Observable.create { observer in
            self.firestore
                .collection("Messages")
                .order(by: "createdAt")
                .addSnapshotListener { documentSnapshot, error in
                    guard let documents = documentSnapshot?.documents else { return }
                    if let error = error {
                        observer.onError(FirebaseErrors.network)
                        print(error)
                        return
                    }
                    
                    var messages: [Message] = []
                    for document in documents {
                        let data = document.data()
                        let decoder = Firestore.Decoder()
                        guard let message = try? decoder.decode(Message.self, from: data) else {
                            observer.onError(FirebaseErrors.decodeError)
                            return
                        }
                        messages.append(message)
                    }
                    
                    observer.onNext(messages)
            }
            return Disposables.create()
        }
    }
    
    func wasSignup() -> Observable<Bool> {
        if let _ = User.name {
            return .just(true)
        } else {
            return .just(false)
        }
    }
}

enum FirebaseErrors: Error {
    case network
    case notSignup
    case decodeError
    case encodeError
    case emptyContent
    
    var message: String {
        switch self {
        case .network:
            return "ネットワークと接続してください"
        case .emptyContent:
            return "メッセージが空です"
        case .notSignup:
            return "サインアップしてください"
        case .decodeError:
            return "デコードに失敗しました"
        case .encodeError:
            return "エンコードに失敗しました"
        }
    }
}
