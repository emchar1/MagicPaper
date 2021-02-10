//
//  ImageLoader.swift
//  MagicPaper
//
//  Created by Eddie Char on 2/9/21.
//

import UIKit


// MARK: - UIImageView extension

extension UIImageView {
    func loadImage(at url: URL) {
        UIImageLoader.loader.load(url, for: self)
    }
    
    func cancelImageLoad() {
        UIImageLoader.loader.cancel(for: self)
    }
}


// MARK: - UIImageLoader

class UIImageLoader {
    static let loader = UIImageLoader()
    
    private let imageLoader = ImageLoader()
    private var uuidMap = [UIImageView: UUID]()
    
    private init() {
        
    }
    
    func load(_ url: URL, for imageView: UIImageView) {
        //1 We initiate the image load using the URL that was passed to load(_:for:).
        let token = imageLoader.loadImage(url) { (result) in
            //2 When the load is completed, we need to clean up the uuidMap by removing the UIImageView for which we’re loading the image from the dictionary.
            defer {
                self.uuidMap.removeValue(forKey: imageView)
            }
            
            do {
                //3 The image is extracted from the result and set on the image view itself.
                let image = try result.get()
                
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
            catch {
                print("Error getting image: \(error.localizedDescription)")
            }
        }
        
        //4 Lastly, if we received a token from the image loader, we keep it around in the [UIImageView: UUID] dictionary so we can reference it later if the load has to be canceled.
        if let token = token {
            uuidMap[imageView] = token
        }
    }
    
    func cancel(for imageView: UIImageView) {
        if let uuid = uuidMap[imageView] {
            imageLoader.cancelLoad(uuid)
            uuidMap.removeValue(forKey: imageView)
        }
    }
}


// MARK: - ImageLoader
class ImageLoader {

    typealias Handler = (Result<UIImage, Error>) -> Void
    private var runningRequests = [UUID: URLSessionTask]()
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 75
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()
    
    
    func loadImage(_ url: URL, _ completion: @escaping Handler) -> UUID? {
        
        //1 If the URL already exists as a key in our in-memory cache, we can immediately call the completion handler. Since there is no active task and nothing to cancel later, we can return nil instead of a UUID instance.
        if let image = self.cache.object(forKey: url as NSURL) {
            completion(.success(image))
            return nil
        }
        
        //2 We create a UUID instance that is used to identify the data task that we’re about to create.
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //3 When the data task completed, it should be removed from the running requests dictionary. We use a defer statement here to remove the running task before we leave the scope of the data task’s completion handler.
            defer { self.runningRequests.removeValue(forKey: uuid) }
            
            //4 When the data task completes and we can extract an image from the result of the data task, it is cached in the in-memory cache and the completion handler is called with the loaded image. After this, we can return from the data task’s completion handler.
            if let data = data, let image = UIImage(data: data) {
                self.cache.setObject(image, forKey: url as NSURL)
                completion(.success(image))
                return
            }
            
            //5 If we receive an error, we check whether the error is due to the task being canceled. If the error is anything other than canceling the task, we forward that to the caller of loadImage(_:completion:).
            guard let error = error else {
                //Without an image or an error, we'll just ignore this for now. You could add your own special error cases for this scenario.
                return
            }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
            
            //The request was cancelled, no need to call the callback
        }
        task.resume()
        
        //6 The data task is stored in the running requests dictionary using the UUID that was created in step 2. This UUID is then returned to the caller.
        runningRequests[uuid] = task
        return uuid
    }
    
    /**
     Receives a UUID, uses it to find a running task and cancels (and removes) the task from the dictionary.
     - parameter uuid: the UUID to cancel
     */
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
        
}
