//
//  UserViewModel.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit
import APIKit
import RxSwift
import Action
import RxRelay

protocol UserViewModelInputs {
    var fetchTriger: PublishSubject<Void> { get }
    var reachedBottomTriger: PublishSubject<Void> { get }
}

protocol UserViewModelOutputs {
    var userInfo: Observable<UserItem> { get }
    var userRepos: Observable<[Repository]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<NSError> { get }
}

protocol UserViewModelType {
    var inputs: UserViewModelInputs { get }
    var outputs: UserViewModelOutputs { get }
}

final class UserViewModel: UserViewModelType, UserViewModelInputs, UserViewModelOutputs {
    var inputs: UserViewModelInputs { return self }
    var outputs: UserViewModelOutputs { return self }
    
    // MARK: - Inputs
    var fetchTriger = PublishSubject<Void>()
    var reachedBottomTriger = PublishSubject<Void>()
    private var page = BehaviorRelay<Int>(value: 1)
    
    // MARK: - Outputs
    var userInfo: Observable<UserItem>
    let userRepos: Observable<[Repository]>
    let isLoading: Observable<Bool>
    let error: Observable<NSError>
    private let getUserAction: Action<Void, UserItem>
    private let getUserReposAction: Action<Int, [Repository]>
    private let disposeBag = DisposeBag()
    
    init(username: String) {
        self.getUserAction = Action {
                return Session.rx_send(request: GetUserDetail(username: username))
        }
        
        self.getUserReposAction = Action { page in
            return Session.rx_send(request: GetUserRepositories(username: username, page: page))
        }
        let user = PublishRelay<UserItem>()
        let repositories = BehaviorRelay<[Repository]>(value: [])
        
        self.userInfo = user.asObservable()
        
        self.userRepos = repositories.asObservable()
        
        self.isLoading = Observable.merge(getUserAction.executing.startWith(false), getUserReposAction.executing.startWith(false))
        self.error = Observable
            .merge(getUserAction.errors, getUserReposAction.errors)
            .map{ _ in
                NSError(domain: "Network Error", code: 0, userInfo: nil)
            }
        
        userInfo = getUserAction.elements
        
        getUserReposAction.elements
            .withLatestFrom(repositories) { ($0, $1) }
            .map { $0.1 + $0.0 }
            .bind(to: repositories)
            .disposed(by: disposeBag)
        
        getUserReposAction.elements
            .withLatestFrom(page)
            .map { $0 + 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
        fetchTriger
            .bind(to: getUserAction.inputs)
            .disposed(by: disposeBag)
        
        fetchTriger
            .withLatestFrom(page)
            .bind(to: getUserReposAction.inputs)
            .disposed(by: disposeBag)
        
        reachedBottomTriger
        .withLatestFrom(isLoading)
            .filter{ !$0 }
            .withLatestFrom(page)
            .filter{ $0 < 5}
            .bind(to: getUserReposAction.inputs)
            .disposed(by: disposeBag)
    }
}
