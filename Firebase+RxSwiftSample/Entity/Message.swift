//
//  Message.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import FirebaseFirestoreSwift

struct Message: Codable, Equatable {
    let name: String
    let content: String
    let imageName: String
    let createdAt: Date = Date()
}
