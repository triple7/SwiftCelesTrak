import Foundation

public struct CelesTrakSyslog:CustomStringConvertible {
    let log:CelesTrakError
    let message:String
    
    public init( log: CelesTrakError, message: String) {
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
     * targets: dictionary of targets with id as key and parameters as value
     * bufferlength: progressive size of download
     * progress: progress in percentage of download for a target set
     * expectedContentLength: size in kbytes of data
     */
    public var targets:[String: CelesTrakTarget]
    private var buffer:Int!
    public var progress:Float?
    private var expectedContentLength:Int?
    public var sysLog:[String:CelesTrakSyslog]!
    
    public override init() {
        self.targets = [String: CelesTrakTarget]()
        self.buffer = 0
    }
    
}

 extension SwiftCelesTrak: URLSessionDelegate {

     public func getBatchGroupTargets( groups: inout [String], returnFormat: CelesTrakFormat = .JSON) {
         let serialGroup = DispatchGroup()
         while !groups.isEmpty {
             let groupName = groups.removeFirst()
             serialGroup.enter()
             getGroup(groupName: groupName, returnFormat: returnFormat, { success in
                 serialGroup.leave()
             })
         }
         serialGroup.notify(queue: .main) {
             
         }
     }
     
     public func getGroup(groupName: String, returnFormat: CelesTrakFormat, _ closure: @escaping (Bool)-> Void) {
         /** Gets a single group
          Adds a set of targets into the targets dictionary and adds a response type for further processing
          Params:
          groupName: CelesTrak standard group type
          returnFormat: type of format [Tel, Json, csv, xml]
          closure: whether request was successful
          */
         let target = CelesTrakRequest(target: groupName)
         let configuration = URLSessionConfiguration.ephemeral
     let queue = OperationQueue.main
         let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
         
         let task = session.dataTask(with: target.getURL(objectType: .GROUP, returnFormat: returnFormat)) { [weak self] data, response, error in
             if error != nil {
                 self?.sysLog[groupName] = CelesTrakSyslog(log: .RequestError, message: error!.localizedDescription)
                 closure(false)
                 return
             }
             guard let response = response as? HTTPURLResponse else {
                 self?.sysLog[groupName] = CelesTrakSyslog(log: .RequestError, message: "response timed out")
                 closure(false)
                 return
             }
             if response.statusCode != 200 {
                 let error = NSError(domain: "com.error", code: response.statusCode)
                 self?.sysLog[groupName] = CelesTrakSyslog(log: .RequestError, message: error.localizedDescription)
                 closure(false)
             }

             var gps:[CelesTrakTarget]
             switch returnFormat {
             case .JSON, .JSON_PRETTY:
                 gps = try! JSONDecoder().decode([CelesTrakTarget].self, from: data!)
             case .CSV:
                 let text = String(decoding: data!, as: UTF8.self)
                 gps = self!.parseCsv(text: text)
             default:
                 self?.sysLog["unavailable"] = CelesTrakSyslog(log: .RequestError, message: "type not available")
                 closure(false)
                     return
             }
             for gp in gps {
                 self?.targets[gp.OBJECT_ID] = gp
                 self?.sysLog[gp.OBJECT_ID] = CelesTrakSyslog(log: .Ok, message: "\(gp.OBJECT_ID) downloaded")
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
