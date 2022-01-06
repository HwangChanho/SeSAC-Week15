//
//  GradeCaculator.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/03.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class GradeCaculator: UIViewController {
    
    let maSwitch = UISwitch()
    
    let first = UITextField()
    let second = UITextField()
    let result = UILabel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        Observable.combineLatest(first.rx.text.orEmpty, second.rx.text.orEmpty) { textValue1, textValue2 -> Double in
            
            return ((Double(textValue1) ?? 0.0) + (Double(textValue2) ?? 0.0)) / 2
        }
        .map { $0.description } // ?
        //.map { "\($0) 입니다."}
        .bind(to: result.rx.text) // 전달
        .disposed(by: disposeBag)  // 메모리해제
        
        Observable.of(true)
            .bind(to: maSwitch.rx.isOn) // bind 를 사용할때는 namespace를 통한 접근 필요
            .disposed(by: disposeBag)
        
    }
    
    func setup() {
        view.addSubview(maSwitch)
        maSwitch.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        [first, second, result].forEach {
            view.addSubview($0)
            $0.backgroundColor = .white
        }
        
        first.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.size.equalTo(50)
            make.leading.equalTo(50)
        }
        
        second.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.size.equalTo(50)
            make.leading.equalTo(120)
        }
        
        result.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.size.equalTo(50)
            make.leading.equalTo(200)
        }
    }
}
