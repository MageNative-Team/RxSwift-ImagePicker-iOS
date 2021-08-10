//
//  ViewController.swift
//  rxSwiftImageFilter
//
//  Created by cedcoss on 10/08/21.
//

import UIKit
import RxSwift
class ViewController: UIViewController {

    @IBOutlet weak var selectedPhoto: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        filterButton.isHidden = true
        testingOtherThings()
    }

    func getImageAfterSelection(){
        if let vc = self.presentingViewController as? photosViewController{
            vc.selectedImage.subscribe(onNext: { image in
                self.selectedPhoto.image = image
            }).disposed(by: disposeBag)

        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? photosViewController{
            vc.selectedImage.subscribe(onNext: { image in
                self.selectedPhoto.image = image
            }).disposed(by: disposeBag)

        }
    }
    
    func testingOtherThings(){
        let subj = PublishSubject<String>()
        subj.filter{$0 == "a"}.subscribe(onNext:{ _ in
            print("called")
            
        })
        subj.onNext("b")
        subj.onNext("c")
        subj.onNext("a")
        subj.onNext("a")
    }
}

