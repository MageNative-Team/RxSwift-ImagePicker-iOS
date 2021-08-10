//
//  photosViewController.swift
//  rxSwiftImageFilter
//
//  Created by cedcoss on 10/08/21.
//

import UIKit
import RxSwift
import Photos

class photosViewController: UIViewController {

    @IBOutlet weak var photoColl: UICollectionView!
    
    var photos = [PHAsset]()
    var selectedSubject = PublishSubject<UIImage>()
    var selectedImage : Observable<UIImage>{
        return selectedSubject.asObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populatePhotos()
    }
    
    func populatePhotos(){
        PHPhotoLibrary.requestAuthorization { status in
            switch status{
            case .authorized:

                let asset = PHAsset.fetchAssets(with: .image, options: nil)
                asset.enumerateObjects { (phasset, count, stoper) in
                    self.photos.append(phasset)
                }
                self.photos.reverse()
                print(self.photos)
                DispatchQueue.main.async {
                    self.photoColl.dataSource = self
                    self.photoColl.delegate = self
                    self.photoColl.reloadData()
                }

            default:
                return
            }
        }
    }
    func imageFromPHAsset(Asset:PHAsset,of size:CGSize) -> UIImage {
        let manager = PHImageManager.default()
        var imagetoReturn = UIImage()
        manager.requestImage(for: Asset, targetSize: size, contentMode: .aspectFit, options: nil) { (image, info) in
          
                if let img = image{
                    imagetoReturn = img
                }
        }
        return imagetoReturn
    }
}

extension photosViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionViewCell", for: indexPath) as! photoCollectionViewCell
        cell.photo.image = imageFromPHAsset(Asset: photos[indexPath.item], of: CGSize(width: 120, height: 120))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let manager = PHImageManager.default()
        manager.requestImage(for: photos[indexPath.item], targetSize:  CGSize(width: 300, height: 300), contentMode: .aspectFit, options: nil) { (image, info) in
          
            guard let info = info else {return}
            let degradedImageFlag = info["PHImageResultIsDegradedKey"] as! Bool
            if !degradedImageFlag{
                if let img = image{
                    self.selectedSubject.onNext(img)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}
