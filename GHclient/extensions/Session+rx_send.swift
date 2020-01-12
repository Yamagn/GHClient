//
//  Session+rx_send.swift
//  GHClient
//
//  Created by ymgn on 2020/01/11.
//  Copyright © 2020 ymgn. All rights reserved.
//

import APIKit
import RxSwift

extension Session {
    func rx_send<T: Request>(request: T) -> Observable<T.Response> {
        return Observable.create { observer in
            let task = self.send(request) { result in
                switch result {
                    case .success(let res):
                        observer.on(.next(res))
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error))
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    class func rx_send<T: Request>(request: T) -> Observable<T.Response> {
        return shared.rx_send(request: request)
    }
}
