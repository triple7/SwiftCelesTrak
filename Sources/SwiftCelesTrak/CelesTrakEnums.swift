//
//  File.swift
//  
//
//  Created by Yuma decaux on 26/12/2022.
//

import Foundation

public enum CelesTrakError:Error {
    case NoSuchObject
    case RequestError
    case DataCorrupted
    case Ok
}

public enum CelesTrakType:String, CaseIterable, Identifiable {
    case CATNR //: Catalog Number (1 to 9 digits). Allows return of data for a single catalog number.
        case INTDES //: International Designator (yyyy-nnn). Allows return of data for all objects associated with a particular launch.
            case GROUP //: Groups of satellites provided on the CelesTrak Current Data page.
            case NAME // Satellite Name. Allows searching for satellites by parts of their name.
                case SPECIAL // Special data sets for the GEO Protected Zone (GPZ) or GPZ Plus
                    
                    public var id:String {
                        return self.rawValue
                    }
}

public enum CelesTrakFormat:String, CaseIterable, Identifiable {
/*    case TLE // Three-line element sets. */
/*     case TwoLE // Two-line element sets (no satellite name on Line 0). */
     case XML // OMM XML format including all mandatory elements. 
/*     case KVN // OMM KVN format including all mandatory elements. */
    case JSON // OMM keywords for all GP elements in JSON format.
                                 case JSON_PRETTY // OMM keywords for all GP elements in JSON pretty-print format.
                                case CSV // OMM keywords for all GP elements in CSV format.
    
    public var id:String {
        switch self {
/*         case .TwoLE: return "2LE" */
/*         case .JSON_PRETTY: return "JSON-PRETTY" */
        default: return self.rawValue
        }
    }
}

public enum CelesTrakGroup:String, CaseIterable, Identifiable {
 case last_30_days
case stations
case visual
case active
case analyst
case s1982_092
case s1999_025
case iridium_33_debris
case cosmos_2251_debris
case weather
case noaa
case goes
case resource
case sarsat
case dmc
case tdrss
case argos
case planet
case spire
case geo
case gpz
case gpz_plus
case intelsat
case ses
case iridium
case iridium_NEXT
case starlink
case oneweb
case orbcomm
case globalstar
case swarm
case amateur
case x_comm
case other_comm
case satnogs
case gorizont
case raduga
case molniya
case gnss
case gps_ops
case glo_ops
case galileo
case beidou
case sbas
case nnss
case musson
case science
case geodetic
case engineering
case education
case military
case radar
case cubesat
case other
    
     public var id:String {
switch self {
case .last_30_days: return "last-30-days"
case .s1982_092: return "1982-092"
case .s1999_025: return "1999-025"
case .iridium_33_debris: return "iridium-33-debris"
case .cosmos_2251_debris: return "cosmos-2251-debris"
case .gpz_plus: return "gpz-plus"
case .iridium_NEXT: return "iridium-NEXT"
case .x_comm: return "x-comm"
case .other_comm: return "other-comm"
case .gps_ops: return "gps-ops"
case .glo_ops: return "glo-ops"
default: return self.rawValue
}
}
}


public enum CelesTrakKey:String, CaseIterable, Identifiable {
    case OBJECT_NAME
    case OBJECT_ID
    case EPOCH
    case MEAN_MOTION
    case ECCENTRICITY
    case INCLINATION
    case RA_OF_ASC_NODE
    case ARG_OF_PERICENTER
    case MEAN_ANOMALY
    case EPHEMERIS_TYPE
    case CLASSIFICATION_TYPE
    case NORAD_CAT_ID
    case ELEMENT_SET_NO
    case REV_AT_EPOCH
    case BSTAR
    case MEAN_MOTION_DOT
    case MEAN_MOTION_DDOT
    
    public var id:String {
        return self.rawValue
    }
}
