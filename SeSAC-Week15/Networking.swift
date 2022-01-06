//
//  Networking.swift
//  SeSAC-Week15
//
//  Created by AlexHwang on 2022/01/04.
//

import Foundation

import UIKit
import RxSwift
import RxAlamofire
import SnapKit
import Then

struct Lotto: Codable {
    let totSellamnt: Int
    let returnValue, drwNoDate: String
    let firstWinamnt, drwtNo6, drwtNo4, firstPrzwnerCo: Int
    let drwtNo5, bnusNo, firstAccumamnt, drwNo: Int
    let drwtNo2, drwtNo3, drwtNo1: Int
}

struct Aztro: Codable {
  let color: String
  let compatibility: String
  let currentDate: String
  let dateRange: String
  let description: String
  let luckyNumber: String
  let luckyTime: String
  let mood: String
  
  enum CodingKeys: String, CodingKey {
    case color, compatibility, description, mood
    case currentDate = "current_date"
    case dateRange = "date_range"
    case luckyNumber = "lucky_number"
    case luckyTime = "lucky_time"
  }
    
}

class NetworkViewController: UIViewController {
  
  enum APIError: Error {
    case failure
    case noData
  }
  
  let session = URLSession(configuration: .default)
  let urlString = "https://aztro.sameerkumar.website?sign=taurus&day=today"
  let lotto = "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=967"
  let disposeBag = DisposeBag()
  
  let resultAztro = PublishSubject<Aztro>()
  let lottoResult = PublishSubject<Lotto>()
  let label = UILabel()
  let compatibility = UILabel().then {
    $0.backgroundColor = .white
  }
  
  let descriptionLabel = UILabel().then {
    $0.backgroundColor = .systemIndigo
    $0.numberOfLines = 0
  }
    
  let todayColor = BehaviorSubject(value: "오늘의 컬러")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemTeal
    viewSetup()
    
    let ureqeust = useURLSession()
      .share() //스트림 공유 키워드 // drive안에 내장되어 있다. 아래 urequest 구독자가 2개인데 각각 콜을 하기때문에 API 콜이 두번이 호출된다. 한번만 호출하도록 유지!
      .decode(type: Lotto.self, decoder: JSONDecoder())//RxSwift6
//      .subscribe(onNext: {
//        self.lottoResult.onNext($0)
//      })
//      .disposed(by: disposeBag)
//
    
    ureqeust.subscribe(onNext: { _ in
      print("value1")
    })
      .disposed(by: disposeBag)
    ureqeust.subscribe(onNext: { _ in
      print("value2")
    })
      .disposed(by: disposeBag)
    
//    resultAztro.subscribe(onNext: {
//      self.label.text = $0.color
//    }).disposed(by: disposeBag)

      //=========================
//    lottoResult
//      .subscribe(onNext: { value in
//        DispatchQueue.main.async {
//          self.label.text = value.totSellamnt.description
//        }
//      })
//      .disposed(by: disposeBag)
    //아래 모양처럼 쓰면 메인쓰레드로 변경 할 수 있다.
    //============================
//    lottoResult
//      .observe(on: MainScheduler.instance)
//      .subscribe(onNext: {
//        self.label.text = $0.totSellamnt.description
//      })
//      .disposed(by: disposeBag)
    //위가 번거로워서 bind 또는 drive로 함
      
  }
  
  func viewSetup() {
    //MARK: - View Setup
    view.addSubview(label)
    view.addSubview(compatibility)
    view.addSubview(descriptionLabel)
    label.backgroundColor = .white
    label.textColor = .systemIndigo
    
    label.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().offset(120)
    }
    
    compatibility.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(label.snp.bottom).offset(8)
    }
    
    descriptionLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(8)
      make.centerX.equalToSuperview()
      make.top.equalTo(compatibility.snp.bottom).offset(8)
    }
  }

  func useURLSession(url: String) -> Observable<Data> {
    return Observable.create { observer in
      let url = URL(string: self.lotto)!
      let task = self.session.dataTask(with: url) { data, response, error in
        guard error == nil else {
          observer.onError(APIError.failure)
          return
        }
        //response, data, json encoding 생략
        guard let data = data, let _ = String(data: data, encoding: .utf8) else {
          observer.onError(APIError.noData)
          return
        }
        observer.onNext(data)
        observer.onCompleted()
      }
      task.resume()
      
      return Disposables.create() {
        task.cancel()
      }
    }
  }
  
  func useURLSession() -> Observable<Data> {
    return Observable.create { observer in
      let url = URL(string: self.lotto)!
      let task = self.session.dataTask(with: url) { data, response, error in
        guard error == nil else {
          observer.onError(APIError.failure)
          return
        }
        //response, data, json encoding 생략
        guard let data = data, let _ = String(data: data, encoding: .utf8) else {
          observer.onError(APIError.noData)
          return
        }
        print("taskcall")
        observer.onNext(data)
        observer.onCompleted()
      }
      task.resume()
      
      return Disposables.create() {
        task.cancel()
      }
    }
  }
  
  func rxAlamoSetup() {
    //MARK: - Bind
//    todayColor
//      .bind(to: label.rx.text)
//      .disposed(by: disposeBag)
    
    resultAztro
      .map{$0.color}
      .bind(to: label.rx.text)
      .disposed(by: disposeBag)
    
    resultAztro
      .map{$0.compatibility}
      .bind(to: compatibility.rx.text)
      .disposed(by: disposeBag)
    
    resultAztro
      .map{$0.description}
      .bind(to: descriptionLabel.rx.text)
      .disposed(by: disposeBag)
      
    //MARK: - Subscribe
    json(.post, urlString)
      .subscribe { value in
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) else { fatalError()}
        do {
          let json = try JSONDecoder().decode(Aztro.self, from: data)
          self.resultAztro.onNext(json)
        } catch let error {
          print(error.localizedDescription)
        }
            
      } onError: { error in
        print(error)
      } onCompleted: {
        print("complete")
      } onDisposed: {
        print("disposed")
      }.disposed(by: disposeBag)
  }
}
