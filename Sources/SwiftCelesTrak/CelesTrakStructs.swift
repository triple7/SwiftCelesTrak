//
//  File.swift
//  
//
//  Created by Yuma decaux on 26/12/2022.
//

import Foundation

public struct CelesTrakTarget:Decodable {
    /** CelesTrak target result
     Object in Json format containing all information pertaining to a CelesTrak target
     */

    public let OBJECT_NAME:String
    public let OBJECT_ID:String
    public let EPOCH:String
    public let MEAN_MOTION:Float
    public let ECCENTRICITY:Float
    public let INCLINATION:Float
    public let RA_OF_ASC_NODE:Float
    public let ARG_OF_PERICENTER:Float
    public let MEAN_ANOMALY:Float
    public let EPHEMERIS_TYPE:Int
    public let CLASSIFICATION_TYPE:String
    public let NORAD_CAT_ID:Int
    public let ELEMENT_SET_NO:Int
    public let REV_AT_EPOCH:Int
    public var BSTAR:Float
    public let MEAN_MOTION_DOT:Float
    public let MEAN_MOTION_DDOT:Float

    public init( data: [String]) {
        /** Initializer for csv format process
         Parameters:
         * data: [String]
        
         */
        self.OBJECT_NAME = data[0]
        self.OBJECT_ID = data[1]
        self.EPOCH = data[2]
         self.MEAN_MOTION = Float(data[3]) ?? 0
        self.ECCENTRICITY = Float(data[4]) ?? 0
        self.INCLINATION = Float(data[5]) ?? 0
        self.RA_OF_ASC_NODE = Float(data[6]) ?? 0
        self.ARG_OF_PERICENTER = Float(data[7]) ?? 0
        self.MEAN_ANOMALY = Float(data[8]) ?? 0
        self.EPHEMERIS_TYPE = Int(data[9]) ?? 0
        self.CLASSIFICATION_TYPE = data[10]
        self.NORAD_CAT_ID = Int(data[11]) ?? 0
        self.ELEMENT_SET_NO = Int(data[12]) ?? 0
        self.REV_AT_EPOCH = Int(data[13]) ?? 0
        self.BSTAR = Float(data[14]) ?? 0
        self.MEAN_MOTION_DOT = Float(data[15]) ?? 0
        self.MEAN_MOTION_DDOT = Float(data[16]) ?? 0
    }
    
}

public struct CelesTrakRequest {
    /** CelesTrak request formatter
     Creates a request Url from the API and configured parameters, with some default parameters such as:
     * request type
     return format
     */
    private let APIUrl = "https://celestrak.org/NORAD/elements/gp.php?"
    private(set) var parameters:[String: String]
    private let target:String!
    
    public init(target: String) {
        self.target = target
        self.parameters = [String:String]()
    }

    public func getURL(objectType: CelesTrakType, returnFormat: CelesTrakFormat)->URL {
        /** Returns a formatted request Url
         Params:
         objectType: type of object to request
         returnFormat: return format [TLE, XML, Json, pretty Json, csv]
         */
            var url = URLComponents(string: APIUrl)
        let params = getparameters(objectType, returnFormat)
        url!.queryItems = Array(params.keys).map {URLQueryItem(name: $0, value: params[$0]!)}
            return url!.url!
        }

    private func getparameters(_ objectType: CelesTrakType, _ returnFormat: CelesTrakFormat)->[String: String] {
        /** Returns parameters used for the Url request
         Params:
         objectType: type of object to request
         returnFormat: return format [TLE, XML, Json, pretty Json, csv]
         Returns: [String: String]
         */
        return [objectType.rawValue: self.target, "FORMAT": returnFormat.rawValue]
    }
    
}
