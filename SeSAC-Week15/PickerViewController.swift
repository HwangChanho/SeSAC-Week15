//
//  PickerViewController.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/03.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class PickerViewController: UIViewController {
    
    let pickerView = UIPickerView()
    let disposeBag = DisposeBag()
    
    let viewModel = PickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
        viewModel.items
            .bind(to: pickerView.rx.itemTitles) { (row, element) in
                return element
            }
            .disposed(by: disposeBag)
        
        pickerView.rx.modelSelected(String.self)
            .subscribe { event in
                print("Picker Selected", event)
            }
            .disposed(by: disposeBag)
    }
    
    func setUp() {
        view.addSubview(pickerView)
        pickerView.backgroundColor = .white
        pickerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
    }
}

class PickerView {
    let items = Observable.just([
        "추웡",
        "너무 추웡",
        "깨추웡"
    ])
}
