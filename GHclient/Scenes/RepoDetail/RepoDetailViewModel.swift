//
//  RepoDetailViewModel.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import RxSwift
import RxRelay
import Action
import APIKit

protocol RepoDetailViewModelInputs {
    var fetchTrigger: PublishSubject<Void> { get }
}

protocol RepoDetailViewModelOutputs {
    var repository: Repository { get }
    var contents: Observable<[Content]> { get }
    var navigationBarTitle: Observable<String> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<NSError> { get }
}

protocol RepoDetailViewModelType {
    var inputs: RepoDetailViewModelInputs { get }
    var outputs: RepoDetailViewModelOutputs { get }
}

final class RepoDetailViewModel: RepoDetailViewModelType, RepoDetailViewModelInputs, RepoDetailViewModelOutputs {
    var inputs: RepoDetailViewModelInputs { return self}
    var outputs: RepoDetailViewModelOutputs { return self }
    
    // MARK: - Input
    
    let fetchTrigger: PublishSubject<Void> = PublishSubject<Void>()
    
    // MARK: - Output
    let repository: Repository
    let contents: Observable<[Content]>
    let navigationBarTitle: Observable<String>
    let isLoading: Observable<Bool>
    let error: Observable<NSError>
    private let getContentsAction: Action<Void, [Content]>
    private let disposeBag = DisposeBag()
    
    init(repository: Repository) {
        self.repository = repository
        self.navigationBarTitle = Observable.just(repository.fullName)
        self.getContentsAction = Action {
            return Session.rx_send(request: GetContents(username: repository.owner.login, reponame: repository.name))
        }
        
        let contents = BehaviorRelay<[Content]>(value: [])
        
        self.contents = contents.asObservable()
        
        self.isLoading = getContentsAction.executing.startWith(false)
        self.error = getContentsAction.errors.map { _ in
            NSError(domain: "Network Error", code: 0, userInfo: nil)
        }
        
        getContentsAction.elements
            .withLatestFrom(contents)
            .bind(to: contents)
            .disposed(by: disposeBag)
        
        fetchTrigger
            .bind(to: getContentsAction.inputs)
            .disposed(by: disposeBag)
    }
}
