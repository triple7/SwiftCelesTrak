//
//  File.swift
//  
//
//  Created by Yuma decaux on 27/12/2022.
//

import Foundation

extension SwiftCelesTrak {

public func parseCsv(text: String)->[CelesTrakTarget] {
        var gps = text.components(separatedBy: "\n")
        _ = gps.removeFirst()
    _ = gps.removeLast()
        return gps.map{ CelesTrakTarget(data: $0.components(separatedBy: ","))}
    }

    public func parseXml(data: Data)->[CelesTrakTarget] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            
        }
        return [CelesTrakTarget]()
    }
    
}

extension SwiftCelesTrak:XMLParserDelegate {
    
    public func parserDidStartDocument(_ parser: XMLParser) {
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
    }

    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            
    }

    public func parser(_ parser: XMLParser, foundCharacters string: String) {
    }

    public func parserDidEndDocument(_ parser: XMLParser) {
    }
    
}
