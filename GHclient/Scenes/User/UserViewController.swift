//
//  UserViewController.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import KRProgressHUD
import OAuthSwift

class UserViewController: UIViewController {
    
    static func make(with viewModel: UserViewModel) -> UserViewController {
        let userSB = UIStoryboard(name: "User", bundle: nil)
        let userVC = userSB.instantiateViewController(withIdentifier: "User") as! UserViewController
        userVC.viewModel = viewModel
        return userVC
    }
    
    @IBOutlet weak var avaterImage: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: UserViewModelType?
    private let disposeBag = DisposeBag()
    var oauthswift: OAuth2Swift?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let repoNib = UINib(nibName: "RepoCell", bundle: nil)
        tableView.register(repoNib, forCellReuseIdentifier: "RepoCell")
        
        tableView.indexPathsForSelectedRows?.forEach { [weak self] in
            self?.tableView.deselectRow(at: $0, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.viewModel == nil {
            self.viewModel = UserViewModel(username: "")
        }

        viewModel?.outputs.userInfo
            .observeOn(MainScheduler.instance)
            .subscribe{ info in
                self.fullName.text = info.element?.name
                self.userName.text = info.element?.login
                self.avaterImage.kf.setImage(with: .network(URL(string: info.element!.avatarUrl)!))
            }
        .disposed(by: disposeBag)

        viewModel?.outputs.userRepos
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, _, repository in
                let cell: RepoCell = tableView.dequeueReusableCell(withIdentifier: "RepoCell") as! RepoCell
                if repository.isPrivate {
                    let path = Bundle.main.path(forResource: "private", ofType: "png")
                    cell.repoTypeImage.image = UIImage(contentsOfFile: path!)
                } else {
                    let path = Bundle.main.path(forResource: "public", ofType: "png")
                    cell.repoTypeImage.image = UIImage(contentsOfFile: path!)
                }
                cell.repoName.text = repository.name
                cell.repoDesc.text = repository.description
                return cell
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Repository.self)
            .observeOn(MainScheduler.instance)
            .subscribe (onNext: { [weak self] in
                let detailVC = RepoDetailViewController.make(with: RepoDetailViewModel(repository: $0))
                self?.navigationController?.pushViewController(detailVC, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel?.outputs.isLoading
            .subscribe(onNext: {
                if $0 {
                    KRProgressHUD.show()
                } else {
                    KRProgressHUD.dismiss()
                }
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

        tableView.rx.reachedBottom.asObservable()
            .bind(to: (viewModel?.inputs.reachedBottomTriger)!)
            .disposed(by: disposeBag)
        
        if UserDefaults.standard.string(forKey: "ACCESS_TOKEN") == nil {
            let oauthSwift = OAuth2Swift(consumerKey: GH_CLIENT_ID, consumerSecret: GH_CLIENT_SECRET, authorizeUrl: "https://github.com/login/oauth/authorize", accessTokenUrl: "https://github.com/login/oauth/access_token", responseType: "code")
            oauthSwift.authorize(withCallbackURL: URL(string: "GHclient://oauth-callback"), scope: "", state: "GHclient") { results in
                switch results {
                case .success(let (credential, _, _)):
                    print("access_token", credential.oauthToken)
                    UserDefaults.standard.set(credential.oauthToken, forKey: "ACCESS_TOKEN")
                    self.viewModel?.inputs.fetchTriger.onNext(())
                case .failure(let error):
                    print(error)
                    let ac = UIAlertController(title: "認証に失敗しました", message: error.description, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true)
                }
                self.oauthswift = oauthSwift
            }
        } else {
            viewModel?.inputs.fetchTriger.onNext(())
        }
    }
}
