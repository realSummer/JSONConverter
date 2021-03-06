//
//  File.swift
//  JSONConverter
//
//  Created by Yao on 2018/2/7.
//  Copyright © 2018年 Ahmed Ali. All rights reserved.
//

import Foundation

class File {
    
    var header: String!
    
    var isCustomHeader: Int = 0
    
    var prefix: String?
    
    var rootName: String = ""
    
    var parentName: String?
    
    var langStruct: LangStruct!
    
    var contents = [Content]()
    
    init(cacheConfig dic: [String: String]?) {
        self.rootName = dic?["rootName"] ?? "RootClass"
        self.prefix = dic?["prefix"] ?? ""
        self.parentName = dic?["parentName"] ?? ""
        
        let langIndex = Int(dic?["langType"] ?? "0")!
        let structIndex = Int(dic?["structType"] ?? "0")!
        let langType = LangType(rawValue: langIndex)!
        let structType = StructType(rawValue: structIndex)!
        let transStruct = LangStruct(langType: langType, structType: structType)
        self.langStruct = transStruct
        
        self.isCustomHeader = Int(dic?["isCustomHeader"] ?? "0")!
        if self.isCustomHeader == 1 {
            self.header = dic?["header"] ?? ""
        }else {
            self.header = defaultHeaderString()
        }
    }
    
    func content(withPropertyKey key: String) -> Content {
        let content = Content(propertyKey: key, langStruct: langStruct, parentClsName: parentName, prefixStr: prefix)
        return content
    }
    
    func property(withPropertykey key: String, type: PropertyType) -> Property {
        let property = Property(propertyKey: key, type: type, langStruct: langStruct, prefixStr: prefix)
        return property
    }
    
    func toString() -> String {
        var totalStr = header ?? ""
        if langStruct.langType == LangType.Flutter {
            var className = rootName.className(withPrefix: prefix);
            totalStr += "\nimport 'package:json_annotation/json_annotation.dart';\n\npart '\(className.underline()).g.dart';\n"
        }
        
        contents.forEach { (content) in
            totalStr += content.toString()
        }
        
        if StringUtils.isBlank(header) {
            totalStr.removeFistChar()
        }
        
        return totalStr
    }
    
    func toCacheConfig() -> [String: String] {
        return ["header": header, "isCustomHeader": "\(isCustomHeader)","rootName": rootName,
                "prefix": prefix ?? "","parentName": parentName ?? "",
                "langType": "\(langStruct.langType.rawValue)",
                "structType": "\(langStruct.structType.rawValue)"]
    }
    
    func defaultHeaderString() -> String {
        let headerString = """
        //
        //  \(rootName).\(langStruct.langType.suffix)
        //
        //
        //  Created by JSONConverter on \(Date.now(format: "yyyy/MM/dd")).
        //  Copyright © \(Date.now(format: "yyyy"))年 JSONConverter. All rights reserved.
        //
        
        """
        return headerString
    }
}
