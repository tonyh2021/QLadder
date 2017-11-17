//
//  MMDB.swift
//  MMDB
//
//  Created by Lex on 12/16/15.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import Foundation

public struct MMDBContinent {
    public var code: String?
    public var names: [String: String]?
}

public struct MMDBCountry: CustomStringConvertible {
    public var continent = MMDBContinent()
    public var isoCode = ""
    public var names = [String: String]()

    init(dictionary: NSDictionary) {
        if let dict = dictionary["continent"] as? NSDictionary,
            let code = dict["code"] as? String,
            let continentNames = dict["names"] as? [String: String]
        {
            continent.code = code
            continent.names = continentNames
        }
        if let dict = dictionary["country"] as? NSDictionary,
            let iso = dict["iso_code"] as? String,
            let countryNames = dict["names"] as? [String: String]
        {
            self.isoCode = iso
            self.names = countryNames
        }
    }
    
    public var description: String {
        var s = "{\n"
        s += "  \"continent\": {\n"
        s += "    \"code\": \"" + (self.continent.code ?? "") + "\",\n"
        s += "    \"names\": {\n"
        var i = continent.names?.count ?? 0
        continent.names?.forEach {
            s += "      \""
            s += $0.0 + "\": \""
            s += $0.1 + "\""
            s += (i > 1 ? "," : "")
            s += "\n"
            i -= 1
        }
        s += "    }\n"
        s += "  },\n"
        s += "  \"isoCode\": \"" + self.isoCode + "\",\n"
        s += "  \"names\": {\n"
        i = names.count
        names.forEach {
            s += "    \""
            s += $0.0 + "\": \""
            s += $0.1 + "\""
            s += (i > 1 ? "," : "")
            s += "\n"
            i -= 1
        }
        s += "  }\n}"
        return s
    }
}

final public class MMDB {

    fileprivate var db = MMDB_s()

    fileprivate typealias ListPtr = UnsafeMutablePointer<MMDB_entry_data_list_s>
    fileprivate typealias StringPtr = UnsafeMutablePointer<String>

    public init?(_ filename: String? = nil) {
        if let filename = filename, openDB(atPath: filename) { return }

        let path = Bundle(for: MMDB.self).path(forResource: "GeoLite2-Country", ofType: "mmdb")
        if let path = path, openDB(atPath: path) { return }

        return nil
    }
    private func openDB(atPath: String) -> Bool {
        let cfilename = (atPath as NSString).utf8String
        let cfilenamePtr = UnsafePointer<Int8>(cfilename)
        let status = MMDB_open(cfilenamePtr, UInt32(MMDB_MODE_MASK), &db)
        if status != MMDB_SUCCESS {
            print(String(cString: MMDB_strerror(errno)))
            return false
        } else {
            return true
        }
    }

    fileprivate func lookupString(_ s: String) -> MMDB_lookup_result_s? {
        let string = (s as NSString).utf8String
        let stringPtr = UnsafePointer<Int8>(string)

        var gaiError: Int32 = 0
        var error: Int32 = 0

        let result = MMDB_lookup_string(&db, stringPtr, &gaiError, &error)
        if gaiError == noErr && error == noErr {
            return result
        }
        return nil
    }


    fileprivate func getString(_ list: ListPtr) -> String {
        var data = list.pointee.entry_data
        let type = (Int32)(data.type)

        // Ignore other useless keys
        guard data.has_data && type == MMDB_DATA_TYPE_UTF8_STRING else {
            return ""
        }

        let str = MMDB_get_entry_data_char(&data)
        let size = size_t(data.data_size)
        let cKey = mmdb_strndup(str, size)
        let key = String(cString: cKey!)
        free(cKey)

        return key
    }

    fileprivate func getType(_ list: ListPtr) -> Int32 {
        let data = list.pointee.entry_data
        return (Int32)(data.type)
    }

    fileprivate func getSize(_ list: ListPtr) -> UInt32 {
        return list.pointee.entry_data.data_size
    }

    private func dumpList(_ list: ListPtr?, toS: StringPtr) -> ListPtr? {
        var list = list
        switch getType(list!) {

        case MMDB_DATA_TYPE_MAP:
            toS.pointee += "{\n"
            var size = getSize(list!)

            list = list?.pointee.next
            while size != 0 && list != nil {
                toS.pointee += "\"" + getString(list!) + "\":"

                list = list?.pointee.next
                list = dumpList(list, toS: toS)
                size -= 1
            }
            toS.pointee += "},"
            break

        case MMDB_DATA_TYPE_UTF8_STRING:
            toS.pointee += "\"" + getString(list!) + "\","
            list = list?.pointee.next
            break

        case MMDB_DATA_TYPE_UINT32:
            if let entryData = list?.pointee.entry_data {
                var mutableEntryData = entryData
                if let uint = MMDB_get_entry_data_uint32(&mutableEntryData) {
                toS.pointee += String(
                    format: "%u",
                    uint
                    ) + ","
                }
            }
            list = list?.pointee.next
            break

        default: ()

        }
        
        if let list = list {
            return list
        }
        return nil
    }

    fileprivate func lookupJSON(_ s: String) -> String? {
        guard let result = lookupString(s) else {
            return nil
        }

        var entry = result.entry
        var list: ListPtr?

        let status = MMDB_get_entry_data_list(&entry, &list)
        if status != MMDB_SUCCESS {
            return nil
        }

        var JSONString = ""
        _ = dumpList(list, toS: &JSONString)

        JSONString = JSONString.replacingOccurrences(
            of: "},},},",
            with: "}}}"
        )

        MMDB_free_entry_data_list(list)

        return JSONString
    }

    public func lookup(_ IPString: String) -> MMDBCountry? {
        guard let s = lookupJSON(IPString) else {
            return nil
        }

        guard let data = s.data(using: String.Encoding.utf8) else {
            return nil
        }

        let JSON = try? JSONSerialization.jsonObject(
            with: data,
            options: JSONSerialization.ReadingOptions.allowFragments)

        guard let dict = JSON as? NSDictionary else {
            return nil
        }

        let country = MMDBCountry(dictionary: dict)

        return country
    }

    deinit {
        MMDB_close(&db)
    }

}
