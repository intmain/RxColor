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
    @IBOutlet weak var collectionView: UICollectionView!
    var disposeBag = DisposeBag()
    var colors: BehaviorSubject<[UIColor]> = BehaviorSubject(value: [UIColor.yellow, UIColor.cyan, UIColor.magenta])
    
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
                guard let `self` = self else { return }
                var colors = (try? self.colors.value()) ?? []
                colors.append(color)
                self.colors.onNext(colors)
            }).disposed(by: disposeBag)
        
        colors.asObservable().bind(to: collectionView.rx.items(cellIdentifier: "ColorCell", cellType: UICollectionViewCell.self)) { (index, color, cell) in
            cell.contentView.backgroundColor = color
            }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                let item = indexPath.item
                var colors = (try? self.colors.value()) ?? []
                colors.remove(at: item)
                self.colors.onNext(colors)
            }).disposed(by: disposeBag)
    }
}
