//
//  PhotoModel.swift
//  FlickrGallery
//
//  Created by Mohammed Ajas on 10/12/17.
//  Copyright © 2017 Mohammed Ajas. All rights reserved.
//

import Foundation

class PhotoModel {
    
    var title : String
    var thumbnail : Data?
    let photoID : String
    let farm : Int
    let server : String
    let secret : String
    
    init (photoID:String,farm:Int, server:String, secret:String, title: String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
    }
    
    func imageURL(_ size:String = "m") -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
            return url
        }
        return nil
    }
    
    
    
    
    
}
