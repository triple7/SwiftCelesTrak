import Foundation

public struct CelesTrakSyslog:CustomStringConvertible {
    let timecode:String
    let log:CelesTrakError
    let message:String
    
    public init( log: CelesTrakError, message: String) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy--MM-dd hh:mm:ss"
        self.timecode = dateFormatter.string(from: date)
        self.log = log
                  self.message = message
    }
    
    public var description:String {
        return "\(log): \(message)"
    }
}

public class SwiftCelesTrak:NSObject {
    /** Model holding all CelesTrak target network related processes including Url requests and returned data storage
     
     CelesTrak allows multiple targets in one group but requires batch processing of groups, this class serially retrieves groups, and defaults to the standard groups
     properties:
     * targets: dictionary of targets with id as key and satellite parameters as value
     * bufferlength: progressive size of download
     * progress: progress in percentage of download for a target set
     * expectedContentLength: size in kbytes of data
     */
    public var targets:[String: (_target: CelesTrakTarget, _group: CelesTrakGroup)]
    private var groups:[CelesTrakGroup]
    private var buffer:Int
    public var progress:Float?
    private var expectedContentLength:Int?
    public var sysLog:[CelesTrakSyslog]
    
    public override init() {
        self.targets = [String: (CelesTrakTarget, CelesTrakGroup)]()
        self.groups = [CelesTrakGroup]()
        self.buffer = 0
        self.sysLog = [ CelesTrakSyslog]()
    }
    
    public func getTargets( _ group: CelesTrakGroup)->[CelesTrakTarget] {
        var output = [CelesTrakTarget]()
        for t in self.targets.values {
            if t._group == group {
                output.append(t._target)
            }
        }
        return output
    }

    public func printLogs() {
        for log in sysLog {
            print(log.description)
        }
    }
}

 extension SwiftCelesTrak: URLSessionDelegate {

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
var gotError = false
                           if error != nil {
                               self.sysLog.append(CelesTrakSyslog(log: .RequestError, message: error!.localizedDescription))
                               gotError = true
                           }
                           if (response as? HTTPURLResponse) == nil  {
                               self.sysLog.append(CelesTrakSyslog(log: .RequestError, message: "response timed out"))
                               gotError = true
                           }
                           let urlResponse = (response as! HTTPURLResponse)
                           if urlResponse.statusCode != 200 {
                               let error = NSError(domain: "com.error", code: urlResponse.statusCode)
                               self.sysLog.append(CelesTrakSyslog(log: .RequestError, message: error.localizedDescription))
                               gotError = true
                           }

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
             if error != nil {
                 self?.sysLog.append(CelesTrakSyslog(log: .RequestError, message: error!.localizedDescription))
                 closure(false)
                 return
             }
             guard let response = response as? HTTPURLResponse else {
                 self?.sysLog.append(CelesTrakSyslog(log: .RequestError, message: "response timed out"))
                 closure(false)
                 return
             }
             if response.statusCode != 200 {
                 let error = NSError(domain: "com.error", code: response.statusCode)
                 self?.sysLog.append(CelesTrakSyslog(log: .RequestError, message: error.localizedDescription))
                 closure(false)
                 return
             }

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

     public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
         expectedContentLength = Int(response.expectedContentLength)
     }
     
     public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
         buffer += data.count
         let percentageDownloaded = Float(buffer) / Float(expectedContentLength!)
            progress =  percentageDownloaded
     }

}
