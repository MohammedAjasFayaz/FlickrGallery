//
//  RestServices.swift
//  FlickrGallery
//
//  Created by Mohammed Ajas on 10/12/17.
//  Copyright © 2017 Mohammed Ajas. All rights reserved.
//

import Foundation
private let apiKey = "599ab9f655e622f62c05887139e0613e"
class RestServices {
    let Queue = OperationQueue()
    
    func recentFlickrPhoto(completion : @escaping (_ results: PhotoResultContoller?, _ error : NSError?) -> Void){
        
        let Error = NSError(domain: "LatestFlickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
       
        guard let latestURL = getRecentPhotosUrl() else {
            completion(nil, Error)
            return
        }
        
        let request = URLRequest(url : latestURL)
        postHttpRequest(urlRequest: request, APIError: Error, completion: completion)
}
    
    //MARK: - Generating the URL
    private func getRecentPhotosUrl() -> URL? {
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&per_page=50&format=json&nojsoncallback=1"
        guard let url = URL(string:URLString) else {
            return nil
        }
        return url
    }
    
    //MARK: - Getting Json and Paring
    private func postHttpRequest(urlRequest : URLRequest, APIError : NSError,completion : @escaping (_ results: PhotoResultContoller?, _ error : NSError?) -> Void)
    {
        
         URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let _ = error {
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    OperationQueue.main.addOperation({
                        completion(nil,APIError)
                    })
                    return
            }
            do {
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String else {
                        OperationQueue.main.addOperation({
                            completion(nil,APIError)
                        })
                        return
                }
                switch (stat) {
                case "ok":
                    print("API Call Success")
                default:
                    OperationQueue.main.addOperation({
                        completion(nil,APIError)
                    })
                    return
                }
                
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    OperationQueue.main.addOperation({
                        completion(nil,APIError)
                    })
                    return
                }
                
                var flickrPhotos = [PhotoModel]()
                for photoObject in photosReceived {
                    guard let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String,
                        let title = photoObject["title"] as? String else {
                            break
                    }
                    let flickrPhoto = PhotoModel(photoID: photoID, farm: farm, server: server, secret: secret,title: title)
                    
                    guard let url = flickrPhoto.imageURL(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }
                    flickrPhoto.thumbnail = imageData
                    flickrPhotos.append(flickrPhoto)
                }
                
                OperationQueue.main.addOperation({
                    completion(PhotoResultContoller(photoList: flickrPhotos), nil)
                })
                
            } catch _ {
                completion(nil, nil)
                return
            }
        }).resume()
    }
    
}
