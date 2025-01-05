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
    internal var groups:[CelesTrakGroup]
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
     
     public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
         expectedContentLength = Int(response.expectedContentLength)
     }
     
     public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
         buffer += data.count
         let percentageDownloaded = Float(buffer) / Float(expectedContentLength!)
            progress =  percentageDownloaded
     }

}
