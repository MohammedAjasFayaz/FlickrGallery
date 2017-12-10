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
    private var searches = [PhotoResultContoller]()
}

extension CollectionViewController{
    
    override func viewDidLoad() {
        callLatestPhotos()
    }
    func photoForIndexPath(_ indexPath: IndexPath) -> PhotoModel {
        return  searches[(indexPath as NSIndexPath).section].photoList[(indexPath as NSIndexPath).row]
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }
    
    //2
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searches[section].photoList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdetifier, for: indexPath) as! PhotoCell
       // cell.PhotoView.image = UIImage.init(named: "Ajas_formal.jpg")
    
        let flickrPhoto = photoForIndexPath(indexPath)
        

        if let image = UIImage(data : flickrPhoto.thumbnail!) {
             cell.PhotoView.image = image
           
        }
        cell.PhotoTitle.text = flickrPhoto.title
        return cell
    }
    
    
    
    func callLatestPhotos()
    {
        let  activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()

        
        flickr.searchFlickrForTerm(){
            results, error in
         activityIndicator.removeFromSuperview()
            
            if let error = error {
                // 2
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                // 3
                self.searches.insert(results, at: 0)
                
                // 4
                self.collectionView?.reloadData()
            }
            
        }
}
}
    

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

