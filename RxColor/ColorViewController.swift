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
    @IBOutlet weak var graySlider: UISlider!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

}

extension ColorViewController {
    func bind() {
        graySlider.rx.value
            .map {
                UIColor(white: CGFloat($0), alpha: 1)
            }.subscribe(onNext: { [weak self] (color: UIColor) in
                self?.colorView.backgroundColor = color
            }).disposed(by: disposeBag)
    }
}
