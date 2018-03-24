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
import RxDataSources
import RxSwiftExt

class SelectedColorViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reverseButton: UIBarButtonItem!
    var disposeBag = DisposeBag()
    var colors: BehaviorSubject<[UIColor]> = BehaviorSubject(value: [UIColor.yellow, UIColor.cyan, UIColor.magenta])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.refreshControl = UIRefreshControl()
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
        
        typealias Section = AnimatableSectionModel<String, UIColor>
        let datasource: RxCollectionViewSectionedAnimatedDataSource<Section> = RxCollectionViewSectionedAnimatedDataSource(configureCell: { (datasource, collectionView, indexPath, color) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
            cell.contentView.backgroundColor = color
            return cell
        }, configureSupplementaryView: { (datasource, collectionView, string, indexPath) -> UICollectionReusableView in
            return collectionView.dequeueReusableSupplementaryView(ofKind: string, withReuseIdentifier: "a", for: indexPath)
        })
        
        colors.map { [Section(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: datasource) )
            .disposed(by:disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                let item = indexPath.item
                var colors = (try? self.colors.value()) ?? []
                colors.remove(at: item)
                self.colors.onNext(colors)
            }).disposed(by: disposeBag)
        
        reverseButton.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            let colors = (try? self.colors.value()) ?? []
            self.colors.onNext(colors.reversed())
        }).disposed(by: disposeBag)
        
        collectionView.rx.contentOffset.pairwise().map { (point1, point2) -> Bool in
            let gap = point1.y - point2.y
            return gap > 0
            }.distinctUntilChanged()
            .subscribe(onNext: {[weak self] (direction: Bool) in
                guard let `self` = self else { return }
                self.collectionView.backgroundColor = UIColor.white
                UIView.animate(withDuration: 0.2, animations: {
                    self.collectionView.backgroundColor = UIColor.orange
                }, completion: { (completion) in
                    self.collectionView.backgroundColor = UIColor.white
                })
            }).disposed(by: disposeBag)
        
        collectionView.refreshControl?.rx
            .controlEvent(UIControlEvents.valueChanged)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                let colors = (try? self.colors.value()) ?? []
                self.colors.onNext(colors.reversed())
                self.collectionView.refreshControl?.endRefreshing()
            }).disposed(by: disposeBag)
            
        
    }
}

extension UIColor: IdentifiableType  {
    public var identity : Int {
        return self.cgColor.hashValue
    }
}
