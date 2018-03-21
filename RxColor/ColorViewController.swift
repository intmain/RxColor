//
//  ColorViewController.swift
//  RxColor
//
//  Created by leonard on 2018. 3. 21..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ColorViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
}

extension ColorViewController {
    func bind() {
        
        Observable
            .combineLatest(redSlider.rx.value, greenSlider.rx.value, blueSlider.rx.value) { (redValue, greenValue, blueValue) -> UIColor in
                UIColor(red: CGFloat(redValue), green: CGFloat(greenValue), blue: CGFloat(blueValue), alpha: 1.0)
            }.subscribe(onNext: { [weak self] (color: UIColor) in
                self?.colorView.backgroundColor = color
            }).disposed(by: disposeBag)
    }
}
