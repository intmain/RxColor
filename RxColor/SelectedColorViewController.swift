//
//  ViewController.swift
//  RxColor
//
//  Created by leonard on 2018. 3. 22..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SelectedColorViewController: UIViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension SelectedColorViewController {
    func bind() {
        addButton.rx.tap.flatMap { [weak self] _ in
            return ColorViewController.rx.create(parent: self)
                .flatMap { $0.rx.selectedColor }.take(1)
            }.subscribe(onNext: { [weak self] (color) in
                self?.view.backgroundColor = color
            }).disposed(by: disposeBag)
    }
}
