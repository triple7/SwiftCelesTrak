//
//  Untitled.swift
//  SwiftCelesTrak
//
//  Created by Yuma decaux on 5/1/2025.
//

import Foundation

extension SwiftCelesTrak {

    /** request returned data check
     */
    private func requestIsValid(message: String, error: Error?, response: URLResponse?, data: Data?) -> Bool {
        var gotError = false
        if error != nil {
            self.sysLog.append(CelesTrakSyslog(log: .RequestError, message: error!.localizedDescription))
            gotError = true
        }
        if (response as? HTTPURLResponse) == nil {
            self.sysLog.append(CelesTrakSyslog(log: .RequestError, message: "response timed out"))
            gotError = true
        }
        let urlResponse = (response as! HTTPURLResponse)
        if urlResponse.statusCode != 200 {
            let error = NSError(domain: "com.error", code: urlResponse.statusCode)
            self.sysLog.append(CelesTrakSyslog(log: .RequestError, message: error.localizedDescription))
            gotError = true
        }
        if !gotError && data == nil {
            self.sysLog.append(CelesTrakSyslog(log: .Ok, message: "\(message) downloaded"))
        } else {
            self.sysLog.append(CelesTrakSyslog(log: .DataCorrupted, message: "Data was nil, potential throttle"))
        }
        return !gotError
    }

    
    public func getBatchGroupTargets(groups: [CelesTrakGroup], returnFormat: CelesTrakFormat = .JSON, completion: @escaping (Bool) -> Void) {
        let serialQueue = DispatchQueue(label: "CelesTrakdownloadQueue")
        
        var remainingGroups = groups
        
        // Create a recursive function to handle the download
        func downloadNextGroup() {
            guard !remainingGroups.isEmpty else {
                // All groups have been downloaded, call the completion handler
                completion(true)
                return
            }
            
            let group = remainingGroups.removeFirst()
            let url = CelesTrakRequest(target: group.rawValue).getURL(objectType: .GROUP, returnFormat: returnFormat)
            
            let operation = DownloadOperation(session: URLSession.shared, dataTaskURL: url, completionHandler: { (data, response, error) in

                if self.requestIsValid(message: group.rawValue, error: error, response: response, data: data) && data != nil  {
                    var gotError = false
                    var gps = [CelesTrakTarget]()
                    switch returnFormat {
                    case .JSON, .JSON_PRETTY:
                        gps = try! JSONDecoder().decode([CelesTrakTarget].self, from: data!)
                    case .CSV:
                        let text = String(decoding: data!, as: UTF8.self)
                        gps = self.parseCsv(text: text)
                    default:
                        self.sysLog.append(CelesTrakSyslog(log: .RequestError, message: "type not available"))
                        gotError = true
                    }
                    if !gotError {
                        for gp in gps {
                            self.targets[gp.OBJECT_ID] = (gp, group)
                            if !self.groups.contains(group) {
                                self.groups.append(group)
                            }
                            self.sysLog.append(CelesTrakSyslog(log: .Ok, message: "\(gp.OBJECT_ID) downloaded"))
                        }
                    }
                    
                    // Call the recursive function to download the next group
                    serialQueue.async {
                        downloadNextGroup()
                    }
                }
            })
            
            // Add the operation to the serial queue to execute it serially
            serialQueue.async {
                operation.start()
            }
        }
        
        // Start the download process by calling the recursive function
        serialQueue.async {
            downloadNextGroup()
        }
    }

    
    public func getGroup(groupName: CelesTrakGroup, returnFormat: CelesTrakFormat, _ closure: @escaping (Bool)-> Void) {
        /** Gets a single group
         Adds a set of targets into the targets dictionary and adds a response type for further processing
         Params:
         groupName: CelesTrak standard group type
         returnFormat: type of format [Tel, Json, csv, xml]
         closure: whether request was successful
         */
        let target = CelesTrakRequest(target: groupName.rawValue)
        let configuration = URLSessionConfiguration.ephemeral
    let queue = OperationQueue.main
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        let task = session.dataTask(with: target.getURL(objectType: .GROUP, returnFormat: returnFormat)) { [weak self] data, response, error in
var gps:[CelesTrakTarget]
            switch returnFormat {
            case .JSON, .JSON_PRETTY:
                gps = try! JSONDecoder().decode([CelesTrakTarget].self, from: data!)
            case .CSV:
                let text = String(decoding: data!, as: UTF8.self)
                gps = self!.parseCsv(text: text)
            default:
                self?.sysLog.append(CelesTrakSyslog(log: .RequestError, message: "type not available"))
                closure(false)
                    return
            }
            for gp in gps {
                self?.targets[gp.OBJECT_ID] = (gp, groupName)
                if let hasGroup = self?.groups.contains(groupName) {
                    if !hasGroup {
                        self?.groups.append(groupName)
                    }
                }
                self?.sysLog.append(CelesTrakSyslog(log: .Ok, message: "\(gp.OBJECT_ID) downloaded"))
            }
        closure(true)
            return
    }
    task.resume()
    }


}
