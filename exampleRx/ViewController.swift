//
//  ViewController.swift
//  exampleRx
//
//  Created by Rubén Muñoz López on 24/9/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    let operationQueue = OperationQueue()
    
    
    @IBOutlet weak var buttonLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dateThread: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainThread()
        threadBackground()
        buttonThread()
    }
    
    private func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd.MM.yyyy, HH:mm:ss"
        
        let result = formatter.string(from: date)
        return result
        
    }
    
    private func threadBackground() {
        
        let operationQueueScheduler = OperationQueueScheduler(operationQueue: self.operationQueue)
        
        Observable.just(getDate())
            //ejecuta la operacion en el hilo nuevo
            .observeOn(operationQueueScheduler)
            //convertir Observable en un drive
            .asDriver(onErrorJustReturn: "Not date found")
            //operación de subscripción vinculando el componente de vista con la propiedad rx
            .drive(dateLbl.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func mainThread() {
        //vinculamos un observador al observable a traves de la subscripcion con subscribe, el observable esta definido en onNext, indicamos en el observador que cuando reciba la fecha, se guarde el valor de la fecha
        Observable.just(getDate())
            .subscribe(onNext: { [weak self] date in
                self?.dateThread.text = date
            })
            //evitamos fuga de memoria
            .disposed(by: disposeBag)
    }
    
    private func buttonThread() {
        //manejamos el evento con la propiedad rx del componente
        self.dateButton.rx.tap
            //al observable se le entrega la fecha ya calculada
            .map { [weak self] in self?.getDate()}
            //cuando se esta vinculando a una vista
            .bind(to: buttonLbl.rx.text)
            .disposed(by: disposeBag)
    }
    
    
}

