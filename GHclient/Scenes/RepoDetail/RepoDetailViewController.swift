//
//  RepoDetailViewController.swift
//  GHClient
//
//  Created by ymgn on 2020/01/09.
//  Copyright © 2020 ymgn. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepoDetailViewController: UIViewController {
    static func make(with viewModel: RepoDetailViewModel) -> RepoDetailViewController {
        let repoDetailSB = UIStoryboard(name: "RepoDetail", bundle: nil)
        let repoDetailVC = repoDetailSB.instantiateViewController(withIdentifier: "RepoDetail") as! RepoDetailViewController
        repoDetailVC.viewModel = viewModel
        return repoDetailVC
    }
    @IBOutlet weak var repoDesc: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: RepoDetailViewModelType!
    private var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let repoNib = UINib(nibName: "ContentCell", bundle: nil)
        tableView.register(repoNib, forCellReuseIdentifier: "ContentCell")
        
        tableView.indexPathsForSelectedRows?.forEach { [weak self] in
            self?.tableView.deselectRow(at: $0, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.repoDesc.text = viewModel.outputs.repository.description

        viewModel.outputs.navigationBarTitle
            .observeOn(MainScheduler.instance)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.outputs.contents
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, row, content in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell") as! ContentCell
                if content.type == "dir" {
                    let path = Bundle.main.path(forResource: "directory", ofType: "png")
                    cell.contentType.image = UIImage(contentsOfFile: path!)
                } else {
                    let path = Bundle.main.path(forResource: "file", ofType: "png")
                    cell.contentType.image = UIImage(contentsOfFile: path!)
                }
                cell.contentName.text = content.name
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let ac = UIAlertController(title: "Error \($0)", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.inputs.fetchTrigger.onNext(())
    }

}
