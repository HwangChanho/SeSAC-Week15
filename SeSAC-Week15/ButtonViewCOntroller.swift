//
//  ButtonViewCOntroller.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/06.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import UIKit

class ButtonViewModel: CommonViewModel {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let tap: ControlEvent<Void>
    }
    
    struct Output {
        let text: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let result = input.tap
            .map { "안녕 반가워" }
            .asDriver(onErrorJustReturn: "")
        
        return Output(text: result)
    }
}

class ButtonViewController: UIViewController {
    
    let button = UIButton()
    let label = UILabel()
    
    let viewModel = ButtonViewModel()
    let disposeBag = DisposeBag()
    
    let labelSubject = PublishSubject<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        
    }
    
    func bind() {
        let input = ButtonViewModel.Input(tap: button.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.text
            .drive(label.rx.text)
            .disposed(by: disposeBag)
    }
    
    func create() {
        // 버튼 탭 -> 안녕 반가워! -> 레이블
        // subscribe : 백그라운드 쓰레드
        //*******************************
        let validation = button.rx.tap
            .observe(on: MainScheduler.instance) // 메인쓰레드에서 동작하게끔 UI관련 작업
            .subscribe { empty in // 이벤트 생성
                self.label.text = "안녕 반가워" // 이벤트 처리
            }
            .disposed(by: disposeBag)
        //********************************
        //********************************
        button.rx.tap
            .bind(to: { _ in
                self.label.text = "안녕 반가워"
            })
        //********************************
        //********************************
        button.rx.tap
            .map { "안녕 반가워" }
            .bind(to: label.rx.text)
        //********************************
        //********************************
        button.rx.tap
            .map { "안녕 반가워" }
            .asDriver(onErrorJustReturn: "")
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        //********************************
    }
    
    func setup() {
        view.addSubview(button)
        view.addSubview(label)
        
        button.backgroundColor = .white
        label.backgroundColor = .lightGray
        
        button.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.center.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.leading.equalTo(20)
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
    }
}
