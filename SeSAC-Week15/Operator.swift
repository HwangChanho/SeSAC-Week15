//
//  Operator.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/03.
//

import UIKit
import RxSwift

enum ExError: Error {
    case fail
}

class Operator: UIViewController {
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observable(이벤트): Create -> Subscribe -> next(정상일경우) -> completed / error ( -> disposed(메모리해제) )
        // disposed: deinit
        
        Observable.from(["가", "나", "다", "라", "마"])
            .subscribe { value in
                print("next : \(value)")
            } onError: { error in
                print(error)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        Observable.repeatElement("Alex")
            .take(Int.random(in: 1...10))
            .subscribe { value in
                print("next : \(value)")
            } onError: { error in
                print(error)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        let interval = Observable<Int>.interval(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe { value in
                print("next : \(value)")
            } onError: { error in
                print(error)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            self.disposeBag = DisposeBag()
            
            // interval.dispose()
            
            // self.navigationController?.pushViewController(GradeCaculator(), animated: true)
            //self.present(GradeCaculator(), animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    deinit {
        print("Operator Deinit")
    }
    
    func basic() {
        let items = [3.3, 4.0, 5.0, 3.6, 4.8, 2.2, 4.5]
        let itemB = [2.3, 2.0, 4.8]
        
        Observable.just(items)
            .subscribe {
                print($0)
            }
            .disposed(by: disposeBag)
        
        Observable.of(items, itemB) // 여러개 가능
            .subscribe {
                print($0)
            }
            .disposed(by: disposeBag)
        
        Observable.from(items) // from 각각의 엘리면트가 별도로 전달됨
            .subscribe {
                print($0)
            }
            .disposed(by: disposeBag)
        
        // Observable<Element>
        Observable<Double>.create { observer -> Disposable in
            for i in items {
                if i < 3.0 {
                    // error
                    observer.onError(ExError.fail)
                    break
                }
                observer.onNext(i)
            }
            observer.onCompleted()
            return Disposables.create()
        }.subscribe { value in
            print(value)
        } onError: { error in
            print(error)
        } onCompleted: {
            print("Completed")
        } onDisposed: {
            print("disposed")
        }
        .disposed(by: disposeBag)
    }
}
