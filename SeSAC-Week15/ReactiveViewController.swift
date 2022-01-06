//
//  ReactiveViewController.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/05.
//

import UIKit
import RxSwift
import RxCocoa

struct SampleData {
    var user: String
    var age: Int
    var rate: Double
}

class ReactiveViewModel {
    var data = [
        SampleData(user: "PongDuck", age: 28, rate: 1.5),
        SampleData(user: "PongUk", age: 28, rate: 1.6),
        SampleData(user: "UJung", age: 27, rate: 0.5),
        SampleData(user: "PongWon", age: 29, rate: 2.5),
        SampleData(user: "UglyChoi", age: 27, rate: 2.0),
        SampleData(user: "Byungshin", age: 28, rate: 0.05),
    ]
    
    var list = PublishRelay<[SampleData]>()
    //var list2 = BehaviorSubject<[SampleData]>(value: data)
    
    func fetchData() {
        //list.onNext(data)
        list.accept(data)
    }
    
    func filterData(query: String) {
        let result = query != "" ? data.filter { $0.user.contains(query) } : data
        //list.onNext(result)
        list.accept(result)
    }
}

class ReactiveViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let resetButton = UIButton()
    
    let viewModel = ReactiveViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        // viewModel data -> tableView ???
        viewModel.list
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = "\(element.user): \(element.age)세 (\(element.rate))"
            }
            .disposed(by: disposeBag)
        
        resetButton
            .rx.tap
            .subscribe { _ in
                print("click")
                self.viewModel.fetchData()
            }
            .disposed(by: disposeBag)
        
        searchBar
            .rx.text // 서치바에서 텍스트가 변경이 될 때 이벤트 발생
            .orEmpty // 옵셔널 해제
            .debounce(RxTimeInterval.microseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe { value in
                self.viewModel.filterData(query: value.element ?? "")
            }
            .disposed(by: disposeBag)

        
    }
    
    func setup() {
        navigationItem.titleView = searchBar
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(resetButton)
        resetButton.backgroundColor = .red
        resetButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func reactiveTest() {
        // sstep1 - normal
        
        var apple = 1
        var banana = 2
        
        print(apple + banana)
        
        apple = 10
        banana = 20
        
        // step2 = Observable + RxSwift
        
        let a = BehaviorSubject(value: 1)
        let b = BehaviorSubject(value: 2)
        
        Observable.combineLatest(a, b) { $0 + $1 }
        .subscribe {
            print($0.element ?? 100)
        }
        .disposed(by: disposeBag)
        
        a.onNext(50)
        a.onNext(10)
    }
}
