//
//  File.swift
//  FlickrGallery
//
//  Created by Mohammed Ajas on 10/12/17.
//  Copyright © 2017 Mohammed Ajas. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController {
    // MARK: - Properties
    private let reuseIdetifier = "cell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow : CGFloat = 2
    private let flickr = RestServices()
    private var resultPhotos = [PhotoResultContoller]()
    private let  activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    //MARK: - View Delegates
    override func viewDidLoad() {
        callLatestPhotos()
    }
    //MARK: - Calling Recent updated RestServices
    func callLatestPhotos()
    {
        addLoader()
        flickr.recentFlickrPhoto()
            {
                results, error in
                DispatchQueue.main.async {
                    self.activityIndicator.removeFromSuperview()
                    
                }
                if let error = error {
                    print("Error searching : \(error)")
                    return
                }
                if let results = results {
                    self.resultPhotos.insert(results, at: 0)
                    self.collectionView?.reloadData()
                }
        }
    }
    //MARK: -Placing ActivityIndicator
    func addLoader()
    {
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
    }
    
}
//MARK: - Search TextField Delegates
extension CollectionViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addLoader()
        flickr.searchFlickrPhoto(textField.text!)
        {
            results, error in
            DispatchQueue.main.async {
                self.activityIndicator.removeFromSuperview()
                
            }
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            if let results = results {
                self.resultPhotos.insert(results, at: 0)
                self.collectionView?.reloadData()
            }
        }
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - CollectionView Datasources Methods
extension CollectionViewController
{
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModel {
        return  resultPhotos[(indexPath as NSIndexPath).section].photoList[(indexPath as NSIndexPath).row]
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return resultPhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return resultPhotos[section].photoList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdetifier, for: indexPath) as! PhotoCell
        let flickrPhoto = photoForIndexPath(indexPath)
        if let image = UIImage(data : flickrPhoto.thumbnail!) {
            cell.PhotoView.image = image
            
        }
        cell.PhotoTitle.text = flickrPhoto.title
        return cell
    }
}


extension CollectionViewController  {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let actionSheet = UIAlertController.init(title: "Please choose a source type", message: nil, preferredStyle: .actionSheet)
        //Getting the particular indexpath image details
        let flickrPhoto = photoForIndexPath(indexPath)
        
        actionSheet.addAction(UIAlertAction.init(title: "Open in Browser", style: UIAlertActionStyle.default, handler: { (action) in
            guard  let url = flickrPhoto.imageURL() else{
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }

        }))
        actionSheet.addAction(UIAlertAction.init(title: "Save to Gallery", style: UIAlertActionStyle.default, handler: { (action) in
            
            guard  let imageData = flickrPhoto.thumbnail  else{
                return
            }
            let saveImageData = UIImage(data: imageData)
            UIImageWriteToSavedPhotosAlbum(saveImageData!, nil, nil, nil)
            let alert = UIAlertController(title: "Completed", message: "Image has been saved!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
            
        }))
        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        //Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        
        
    
    }
}

//MARK: - CollectionView Layout Methods
extension CollectionViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    
    
    
}

