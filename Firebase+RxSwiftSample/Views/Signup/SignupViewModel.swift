//
//  SignupViewModel.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SignupViewModel {
    let imageData: PublishRelay<Data?> = .init()
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let isSuccessed = PublishSubject<Void>()
    let isError = PublishSubject<String>()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(name: Observable<String?>, doneButtonTapped: Observable<Void>, model: signupModelProtocol = SignupModel()) {
        
        let signupResult = doneButtonTapped
            .withLatestFrom(Observable.combineLatest(name, imageData))
            .flatMap { [isLoading] name, imageData -> Observable<Void> in
                isLoading.accept(true)
                guard let _name = name else { return .error(SignupErrors.nameNotfound)}
                return model.signup(with: SignupData(name: _name, imageData: imageData))
                    .asObservable()
            }
        
        signupResult
            .subscribe( onNext: { [isLoading, isSuccessed] _ in
                isSuccessed.onNext(())
                isLoading.accept(false)
            }, onError: { [isLoading, isError] error in
                if let _error = error as? FirebaseErrors {
                    isError.onNext(_error.message)
                } else {
                    isError.onNext("unknown error")
                }
                
                isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
}
