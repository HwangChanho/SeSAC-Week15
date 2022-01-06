//
//  Subject.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/04.
//

import UIKit
import SnapKit
import RxSwift

class SubjectViewController: UIViewController {
    
    let label = UILabel()
    let nickname = PublishSubject<String>() //Observable.just("Alex")
    let disposeBag = DisposeBag()
    
    // PublishSubject: Observable + Observer
    
    let array1 = [1, 1, 1, 1, 1]
    let array2 = [2, 2, 2, 2, 2]
    let array3 = [3, 4, 3, 3, 3]
    
    let subject = PublishSubject<[Int]>()
    let behavior = BehaviorSubject<[Int]>(value: [0, 0, 0, 0, 0])
    let replay = ReplaySubject<[Int]>.create(bufferSize: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let random1 = Observable<Int>.create { observer in
            observer.onNext(Int.random(in: 1...100))
            observer.onNext(Int.random(in: 1...100))
            observer.onNext(Int.random(in: 1...100))
            return Disposables.create()
        }
        
        random1
            .subscribe { value in
                print("random1 \(value)")
            }
            .disposed(by: disposeBag)
        
        random1
            .subscribe { value in
                print("random2 \(value)")
            }
            .disposed(by: disposeBag)
        
        let randomSubject = BehaviorSubject(value: 0)
        randomSubject.onNext(Int.random(in: 1...100))
        
        randomSubject
            .subscribe { value in
                print("randomSubject1 \(value)")
            }
            .disposed(by: disposeBag)
        
        randomSubject
            .subscribe { value in
                print("randomSubject2 \(value)")
            }
            .disposed(by: disposeBag)
    }
    
    func replayObject() {
        replay.onNext(array1)
        replay.onNext(array2)
        replay.onNext(array3)
        
        replay
            .subscribe { value in
                print("Behavior subject - \(value)")
            } onError: { error in
                print(error)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        replay.onCompleted()
        replay.onNext(array2)
    }
    
    func behaviorSubject() { // 구독전에 값을 담을수 있다.
        behavior.onNext(array1)
        behavior.onNext(array2)
        behavior.onNext(array3)
        
        behavior
            .subscribe { value in
                print("Behavior subject - \(value)")
            } onError: { error in
                print(error)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        behavior.onCompleted()
        // 완료 이후에는 전달 x
    }
    
    func publishSubject() {
        subject.onNext(array1)
        
        subject
            .subscribe { value in
                print("Publish subject - \(value)")
            } onError: { error in
                print(error)
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        subject.onNext(array2)
        subject.onNext(array3)
        subject.onCompleted()
        
        subject.onNext(array1) // 완료된 시점 이루에는 전달 x
    }
    
    func aboutSubject() {
        setup()
        
        nickname
            .bind(to: label.rx.text) // subscribe vs bind(UI적인부분) vs drive
            .disposed(by: disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.nickname.onNext("AlexHwang")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.nickname.onNext("AH")
        }
    }
    
    func setup() {
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.backgroundColor = .white
        label.textAlignment = .center
    }
}
