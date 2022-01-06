//
//  ViewController.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/03.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class ViewController: UIViewController {
    
    let tableView = UITableView()
    let disposeBag = DisposeBag() // 메모리 정리
    let label = UILabel()
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
        viewModel.items
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                
                cell.textLabel?.text = "\(element) @ row \(row)"
                
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .map({ data in
                "\(data) 를 클릭했습니다!"
            }) // 데이터 변환
            .bind(to: label.rx.text)
            .disposed(by: disposeBag) // 메모리 해제
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // self.navigationController?.pushViewController(Operator(), animated: true)
            self.present(Operator(), animated: true, completion: nil)
        }
    }
    
    func setUp() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
}

class ViewModel {
    let items = Observable.just([
        "First Item",
        "Second Item",
        "Third Item"
    ])
}
