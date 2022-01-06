//
//  ValidationViewController.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/05.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol CommonViewModel {
    associatedtype Input // 제네릭과 동일
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}

class ValidationViewModel: CommonViewModel {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let text: ControlProperty<String?>
        let tap: ControlEvent<Void>
    }
    
    struct Output {
        let validStatus: Observable<Bool>
        let validText: BehaviorRelay<String>
        let sceneTransition: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let resultText = input.text
            .orEmpty
            .map { $0.count >= 5 }
            .share(replay: 1, scope: .whileConnected)
        
        return Output(validStatus: resultText, validText: validText, sceneTransition: input.tap)
    }
    
    var validText = BehaviorRelay<String>(value: "최소 8자 이상 입력하세요.")
}

class ValidationViewController: UIViewController {
    let nameValidationLabel = UILabel()
    let nameTextField = UITextField()
    let button = UIButton()
    
    let viewModel = ValidationViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //****************************************
//        viewModel.validText
//            .asDriver()
//            .drive(nameValidationLabel.rx.text)
//        //.bind(to: nameValidationLabel.rx.text) 위와 동일
//            .disposed(by: disposeBag)
//
//        let validation = nameTextField.rx.text
//            .orEmpty // 옵셔널 해제
//            .map { $0.count >= 5 }
//            .share(replay: 1, scope: .whileConnected)
//
//        validation
//            .bind(to: button.rx.isEnabled)
//            .disposed(by: disposeBag)
//
//        validation
//            .bind(to: nameValidationLabel.rx.isHidden)
//            .disposed(by: disposeBag)
//
//        button.rx.tap
//            .subscribe { _ in
//                self.present(ReactiveViewController(), animated: true, completion: nil)
//            }
//            .disposed(by: disposeBag)
        //****************************************
        
        setUp()
        bind()
    }
    
    func bind() {
        let input = ValidationViewModel.Input(text: nameTextField.rx.text, tap: button.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.validStatus
            .bind(to: button.rx.isEnabled, nameValidationLabel.rx.isHidden)
            .disposed(by: disposeBag)
        output.validText
            .asDriver()
            .drive(nameValidationLabel.rx.text)
        //.bind(to: nameValidationLabel.rx.text) 위와 동일
            .disposed(by: disposeBag)
        output.sceneTransition
            .subscribe { _ in
                self.present(ReactiveViewController(), animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
    
    func setUp() {
        [nameTextField, button, nameValidationLabel].forEach { make in
            make.backgroundColor = .lightGray
            view.addSubview(make)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
        
        button.snp.makeConstraints { make in
            make.top.equalTo(200)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
        
        nameValidationLabel.snp.makeConstraints { make in
            make.top.equalTo(300)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
    }
}
