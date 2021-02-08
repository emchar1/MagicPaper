//
//  Model.swift
//  MagicPaper
//
//  Created by Eddie Char on 12/21/20.
//

//import UIKit
//import CloudKit
//
//
//// MARK: - Model for CloudKit
//
//struct Model {
//    private let videoExtension = "mov"
//    
//    //Create objects for our container and databases.
//    private let container: CKContainer
//    private let publicDB: CKDatabase
//    private let privateDB: CKDatabase
//    
//    //Initialize the objects.
//    init() {
//        container = CKContainer.default()
//        publicDB = container.publicCloudDatabase
//        privateDB = container.privateCloudDatabase
//    }
//    
//    //4 Create an enum for error handling
//    enum ModelErrors: Error {
//        case noName
//        case noRecord
//        case failedToPerformDBQuery
//    }
//    
//    //5 This is the function that we call from the view controller. It will contain a number of private Model functions.
//    func fetchVideos(videoNames: [String]) {
//        let undownloadedVideos = checkToSeeIfVideosAreAlreadyDownloaded(videoNames: videoNames)
//        let query = getQueryFromNamesArray(names: undownloadedVideos)
//        
//        queryPublicDatabase(query: query)
//    }
//    
//    //This method performs the query and then if it is successful it calls saveVideoToDocumentsDirectory.
//    //SHOULD THIS BE PRIVATE??
//    private func queryPublicDatabase(query: CKQuery) {
//        publicDB.perform(query, inZoneWith: nil) { (results, error) in
//            if let error = error {
//                print("Error getting Item \(error)")
//                return
//            }
//            
////-----
//            DispatchQueue.main.async {
//                results?.forEach({ (record: CKRecord) in
//                    let record = VideosInCloudKit(name: record.value(forKey: "video") as! String, record: record, database: self.publicDB)
//                    
//                    do {
//                        try self.saveVideoToDocumentsDirectory(video: record)
//                    }
//                    catch ModelErrors.noName {
//                        print("ERROR No Name for file")
//                    }
//                    catch ModelErrors.noRecord {
//                        print("ERROR No Record for file")
//                    }
//                    catch {
//                        print(error)
//                    }
//                })
//            }
//        }
//    }
//    
//    
//    // MARK: - Helper Functions
//    
//    private func saveVideoToDocumentsDirectory(video: VideosInCloudKit) throws {
//        //2 These guard statements are a better choice than nested if let statements
//        guard let record = video.record else {
//            throw ModelErrors.noRecord
//        }
//        
//        guard let name = video.name else {
//            throw ModelErrors.noName
//        }
//
////-----
//        //3 We attempt to download and save the video on a background thread so we don't freeze the app while downloading.
//        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
//            let videoFile = record.object(forKey: "MagicVideo") as! CKAsset
//            let videoURL = videoFile.fileURL as URL?
//            
//            do {
//                let videoData = try Data(contentsOf: videoURL!)
//                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//                let destinationPath = NSURL(fileURLWithPath: documentsPath).appendingPathComponent("\(name).mov", isDirectory: false)
//                
//                FileManager.default.createFile(atPath: destinationPath!.path, contents: videoData, attributes: nil)
//            }
//            catch {
//                print("Error downloading video")
//            }
//        }
//    }
//    
//    private func checkToSeeIfVideosAreAlreadyDownloaded(videoNames: [String]) -> [String] {
//        var videoNamesThatNeedToBeDownloaded: [String] = []
//        
//        //1 Grab all the files in the documents directory.
//        let filesInDocsDirectory = DocumentsDirectory.getContentsOfDocumentsDirectory()
//        
//        for videoName in videoNames {
//            //2 Add the extension because that's how our files are going to be titled.
//            let videoNameWithExtension = "\(videoName).\(videoExtension)"
//            
//            if filesInDocsDirectory.contains(videoNameWithExtension) {
//                print("\(videoName) is already downloaded.")
//            }
//            else {
//                print("Need to download \(videoNameWithExtension)")
//                                
//                //3 Note: we don't add extension because when querying from CloudKit, you only need the video name.
//                videoNamesThatNeedToBeDownloaded.append(videoName)
//            }
//        }
//        
//        print(videoNamesThatNeedToBeDownloaded)
//
//        
//        return videoNamesThatNeedToBeDownloaded
//    }
////-----
//    //This will create a CloudKit query with all the un-downloaded video names.
//    private func getQueryFromNamesArray(names: [String]) -> CKQuery {
//        let arrayPredicate = NSPredicate(format: "video IN %@", argumentArray: [names])
//        let query = CKQuery(recordType: "MagicVideo", predicate: arrayPredicate)
//        
//        print("query: \(query)")
//        return query
//    }
//    
//}
//
//
//// MARK: - VideosInCloudKit
//
////This is a reference to the record and it's database in CloudKit. This is only a reference and does not contain the video.
//struct VideosInCloudKit {
//    var name: String!
//    var record: CKRecord!
//    weak var database: CKDatabase!
//    
//    init(name: String, record: CKRecord, database: CKDatabase) {
//        self.name = name
//        self.record = record
//        self.database = database
//    }
//}
//
//
//// MARK: - DocumentsDirectory
//
//struct DocumentsDirectory {
//    static func getContentsOfDocumentsDirectory() -> [String] {
//        let fileManager = FileManager.default
//        var tempArray: [String] = []
//        
//        do {
//            let directoryPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
//            let docsDirectory = directoryPaths[0].path
//            let filelist = try fileManager.contentsOfDirectory(atPath: docsDirectory)
//            
//            for filename in filelist {
//                print(filename)
//                tempArray.append(filename)
//            }
//        }
//        catch {
//            print("Error: \(error.localizedDescription)")
//        }
//        
//        return tempArray
//    }
//}

