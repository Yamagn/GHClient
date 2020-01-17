//
//  SearchViewController.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    static func make(with viewModel: SearchViewModel) -> SearchViewController {
        let searchSB = UIStoryboard(name: "Search", bundle: nil)
        let searchVC = searchSB.instantiateViewController(withIdentifier: "Search") as! SearchViewController
        
        searchVC.viewModel = SearchViewModel()
        return searchVC
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: SearchViewModelType?
    private let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userNib = UINib(nibName: "UserCell", bundle: nil)
        tableView.register(userNib, forCellReuseIdentifier: "UserCell")
        
        tableView.indexPathsForSelectedRows?.forEach { [weak self] in
            self?.tableView.deselectRow(at: $0, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if viewModel == nil {
            self.viewModel = SearchViewModel()
        }
        setupSearchBar()
        
        viewModel?.outputs.users
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, row, user in
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserCell
                cell.avatarImage.kf.setImage(with: URL(string: user.avatarUrl)!)
                cell.userName.text = user.login
                cell.bio.text = user.bio
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(UserItem.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let vc = UserViewController.make(with: UserViewModel(username: $0.login))
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel?.outputs.error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let ac = UIAlertController(title: "Error \($0)", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            })
            .disposed(by: disposeBag)
    }
    func setupSearchBar() {
        searchBar.delegate = self
        
        let debounceInterval = RxTimeInterval.milliseconds(3)
        let incrementalSearchTextObserbal = rx
            .methodInvoked(#selector(UISearchBarDelegate.searchBar(_:shouldChangeTextIn:replacementText:)))
            .debounce(debounceInterval, scheduler: MainScheduler.instance)
            .flatMap { [unowned self] _ in Observable.just(self.searchBar.text ?? "") }
        
        let textObservable = searchBar.rx.text.orEmpty.asObservable()
        let searchTextObservable = Observable.merge(incrementalSearchTextObserbal, textObservable)
            .skip(1)
            .debounce(debounceInterval, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        
        searchTextObservable.subscribe(onNext: { [unowned self] text in
            if !text.isEmpty {
                print(text)
                self.viewModel?.inputs.changeTextTriger.onNext(text)
            }
        }).disposed(by: disposeBag)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
