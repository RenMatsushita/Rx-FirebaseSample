
//
//  MessageTableViewDatasource.swift
//  Firebase+RxSwiftSample
//
//  Created by Ren Matsushita on 2020/02/13.
//  Copyright © 2020 Ren Matsushita. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class MessageTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [Message]
    private var items: Element = []
    var rowCount: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as? MessageTableViewCell else {
            return UITableViewCell()
        }
        cell.update(with: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<[Message]>) {
        Binder<Element>(self) { [rowCount] dataSource, items in
            dataSource.items = items
            rowCount.accept(items.count - 1)
            tableView.reloadData()
        }.on(observedEvent)
    }
}
