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
    @IBOutlet weak var hexColorTextField: UITextField!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var savedColorView: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
}

extension ColorViewController {
    func bind() {
        let color = Observable
            .combineLatest(redSlider.rx.value, greenSlider.rx.value, blueSlider.rx.value) { (redValue, greenValue, blueValue) -> UIColor in
                UIColor(red: CGFloat(redValue), green: CGFloat(greenValue), blue: CGFloat(blueValue), alpha: 1.0)
        }
        
        color
            .subscribe(onNext: { [weak self] (color: UIColor) in
                self?.colorView.backgroundColor = color
            }).disposed(by: disposeBag)
        
        color
            .map { (color: UIColor) -> String in
                color.hexString
            }.subscribe(onNext: { [weak self] (colorString: String) in
                self?.hexColorTextField.text = colorString
            }).disposed(by: disposeBag)
        
        applyButton.rx.tap.asObservable().withLatestFrom(self.hexColorTextField.rx.text)
            .map { (hexText: String?) -> (Int, Int, Int)? in
                return hexText?.rgb
            }.filter { rgb -> Bool in
                return rgb != nil
            }.map { $0! }
            .subscribe(onNext: { [weak self] (red,green,blue) in
                self?.redSlider.rx.value.onNext(Float(red)/255.0)
                self?.redSlider.sendActions(for: .valueChanged)
                self?.greenSlider.rx.value.onNext(Float(green)/255.0)
                self?.greenSlider.sendActions(for: .valueChanged)
                self?.blueSlider.rx.value.onNext(Float(blue)/255.0)
                self?.blueSlider.sendActions(for: .valueChanged)
                self?.view.endEditing(true)
            }).disposed(by: disposeBag)

        saveButton.rx.tap.asObservable().withLatestFrom(colorView.rx.observe(UIColor.self, "backgroundColor")).map { $0! }
            .flatMap { (color: UIColor) -> Observable<UIColor> in
                return ColorArchiveAPI.instance.save(color: color)
            }.subscribe(onNext: { [weak self] (saveColor: UIColor) in
                self?.savedColorView.backgroundColor = saveColor
            }).disposed(by: disposeBag)
        
        loadButton.rx.tap.asObservable()
            .flatMap {  _ -> Observable<UIColor> in
                return ColorArchiveAPI.instance.load()
            }.subscribe(onNext: { [weak self] (savedColor) in
                self?.hexColorTextField.rx.text.onNext(savedColor.hexString)
                self?.hexColorTextField.sendActions(for: .valueChanged)
                self?.applyButton.sendActions(for: .touchUpInside)
            }).disposed(by: disposeBag)
        
        ColorArchiveAPI.instance.load()
            .subscribe(onNext: { [weak self] color in
                self?.savedColorView.backgroundColor = color
            }).disposed(by: disposeBag)
    }
}

extension Reactive where Base: ColorViewController {
    static func create(parent: UIViewController?, animated: Bool = true) -> Observable<ColorViewController> {
        return Observable.create({ [weak parent] (observer) -> Disposable in
            let colorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorViewController") as! ColorViewController
            let dismissDisposable = colorViewController.cancelButton.rx.tap.subscribe(onNext: { [weak colorViewController] _ in
                guard let colorViewController = colorViewController else { return }
                colorViewController.dismiss(animated: true, completion: nil)
            })
            let naviController = UINavigationController(rootViewController: colorViewController)
            parent?.present(naviController, animated: animated, completion: {
                observer.onNext(colorViewController)
            })
            
            return Disposables.create(dismissDisposable, Disposables.create {
                colorViewController.dismiss(animated: animated, completion: nil)
            })
        })
    }
    var selectedColor: Observable<UIColor> {
        return base.doneButton.rx.tap.withLatestFrom(base.colorView.rx.observe(UIColor.self,  "backgroundColor")).map { $0! }
    }
}

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "%.2X%.2X%.2X" , Int(255*red), Int(255*green) ,Int(255*blue))
    }
}

extension String {
    var rgb: (Int, Int, Int)? {
        guard let number: Int = Int(self, radix: 16) else { return nil }
        let blue = number & 0x0000ff
        let green = (number & 0x00ff00) >> 8
        let red = (number & 0xff0000) >> 16
        return (red, green, blue)
    }
}

class ColorArchiveAPI {
    static let instance: ColorArchiveAPI = ColorArchiveAPI()
    var color: UIColor? = nil
    
    func save(color: UIColor) -> Observable<UIColor> {
        self.color = color
        return Observable.just(color).delay(0.7, scheduler: MainScheduler.instance)
    }
    
    func load() -> Observable<UIColor> {
        guard let color = color else {
            return Observable.empty().delay(0.7, scheduler: MainScheduler.instance)
        }
        return Observable.just(color).delay(0.7, scheduler: MainScheduler.instance)
    }
}
