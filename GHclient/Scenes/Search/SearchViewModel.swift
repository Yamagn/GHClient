//
//  SearchViewModel.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import APIKit
import Action

protocol SearchViewModelInputs {
    var changeTextTriger: PublishSubject<String> { get }
    var reachBottomTriger: PublishSubject<String> { get }
}

protocol SearchViewModelOutputs {
    var users: Observable<[UserItem]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<NSError> { get }
}

protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

final class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {
    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }
    
    // MARK: - Inputs
    
    let changeTextTriger: PublishSubject<String> = PublishSubject<String>()
    let reachBottomTriger: PublishSubject<String> = PublishSubject<String>()
    private let page = BehaviorRelay<Int>(value: 1)
    private let searchText = BehaviorRelay<String>(value: "")
    
    // MARK: - Outputs
    
    let users: Observable<[UserItem]>
    let isLoading: Observable<Bool>
    let error: Observable<NSError>
    private let searchAction: Action<(String, Int), [UserItem]>
    private let disposeBag = DisposeBag()
    
    init() {
        self.searchAction = Action { query, page in
            return Session.rx_send(request: SearchUsers(q: query, page: page)).map { $0.items }
        }
        
        let results = BehaviorRelay<[UserItem]>(value: [])
        self.users = results.asObservable()
        self.isLoading = searchAction.executing.startWith(false)
        self.error = searchAction.errors.map { _ in NSError(domain: "Network Error", code: 0, userInfo: nil) }
        
        searchAction.elements
            .bind(to: results)
            .disposed(by: disposeBag)
        
        changeTextTriger
            .withLatestFrom(isLoading) { ($0, $1) }
            .filter { !$0.1 }
            .withLatestFrom(page) { ($0.0, $1) }
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
        
        reachBottomTriger
            .withLatestFrom(page)
            .map { $0 + 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
        reachBottomTriger
            .withLatestFrom(isLoading) { ($0, $1) }
            .filter { !$0.1 }
            .map { $0.0 }
            .withLatestFrom(page) { ($0, $1) }
            .filter { $0.1 < 5}
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
    }
}
