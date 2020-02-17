//
//  User.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/14.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import Foundation

struct User {
    private static let userDefaults: UserDefaults = UserDefaults.standard
    static var name: String? {
        return userDefaults.string(forKey: "name")
    }
    
    static var imageName: String? {
        return userDefaults.string(forKey: "imageName")
    }
}
