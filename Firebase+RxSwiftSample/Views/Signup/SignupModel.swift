//
//  SignupModel.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import RxSwift
import FirebaseStorage

protocol signupModelProtocol {
    func signup(with signupData: SignupData) -> Single<Void>
}

final class SignupModel: signupModelProtocol {
    func signup(with signupData: SignupData) -> Single<Void> {
        let imageName = signupData.name + Date.toString()
        guard let imageData = signupData.imageData else { return .error(SignupErrors.imageNotfound)}
        return Single.create(subscribe: { observer in
            let storageReference = Storage.storage().reference()
            storageReference
                .child("images/\(imageName)")
                .putData(imageData, metadata: nil, completion: { metadata, error in
                    if let error = error {
                        observer(.error(error))
                        return
                    }
                    
                    self.setLocalData(signupData.name, imageName)
                    observer(.success(()))
                })
            return Disposables.create()
        })
    }
    
    private func setLocalData(_ name: String, _ imageName: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(name, forKey: "name")
        userDefaults.set(imageName, forKey: "imageName")
    }
}

enum SignupErrors: Error {
    case nameNotfound
    case imageNotfound
}

extension Date {
    static func toString() -> String {
        let dateFormatter = DateFormatter()
        return dateFormatter.string(from: self.init())
    }
}
