//
//  CleanJSON.swift
//  CleanJSON
//
//  Created by GorXion on 2018/5/3.
//

import Foundation

public extension KeyedDecodingContainer {
    
    public func decode(_ type: Bool.Type, forKey key: KeyedDecodingContainer.Key) throws -> Bool {
        return try decodeIfPresent(type, forKey: key) ?? false
    }
    
    public func decode(_ type: String.Type, forKey key: KeyedDecodingContainer.Key) throws -> String {
        return try decodeIfPresent(type, forKey: key) ?? ""
    }
    
    public func decode(_ type: Double.Type, forKey key: KeyedDecodingContainer.Key) throws -> Double {
        return try decodeIfPresent(type, forKey: key) ?? 0.0
    }
    
    public func decode(_ type: Float.Type, forKey key: KeyedDecodingContainer.Key) throws -> Float {
        return try decodeIfPresent(type, forKey: key) ?? 0.0
    }
    
    public func decode(_ type: Int.Type, forKey key: KeyedDecodingContainer.Key) throws -> Int {
        return try decodeIfPresent(type, forKey: key) ?? 0
    }
    
    public func decode(_ type: UInt.Type, forKey key: KeyedDecodingContainer.Key) throws -> UInt {
        return try decodeIfPresent(type, forKey: key) ?? 0
    }
    
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) throws -> T where T : Decodable {
        
        if let value = try decodeIfPresent(type, forKey: key) {
            return value
        } else if let objectValue = try? JSONDecoder().decode(type, from: "{}".data(using: .utf8)!) {
            return objectValue
        } else if let arrayValue = try? JSONDecoder().decode(type, from: "[]".data(using: .utf8)!) {
            return arrayValue
        }
        let context = DecodingError.Context(codingPath: [key], debugDescription: "Key: <\(key.stringValue)> cannot be decoded")
        throw DecodingError.dataCorrupted(context)
    }
    
    public func decodeIfPresent(_ type: Bool.Type, forKey key: K) throws -> Bool? {
        
        guard contains(key) else { return nil }
        
        let decoder = try superDecoder(forKey: key)
        let container = try decoder.singleValueContainer()
        return try? container.decode(type)
    }
    
    public func decodeIfPresent(_ type: String.Type, forKey key: K) throws -> String? {
        
        guard contains(key) else { return nil }
        
        let decoder = try superDecoder(forKey: key)
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(type) {
            return value
        } else if let intValue = try? container.decode(Int.self) {
            return String(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            return String(doubleValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            return String(boolValue)
        }
        return nil
    }
    
    public func decodeIfPresent(_ type: Double.Type, forKey key: K) throws -> Double? {
        
        guard contains(key) else { return nil }
        
        let decoder = try superDecoder(forKey: key)
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(type) {
            return value
        } else if let stringValue = try? container.decode(String.self) {
            return Double(stringValue)
        }
        return nil
    }
    
    public func decodeIfPresent(_ type: Float.Type, forKey key: K) throws -> Float? {
        
        guard contains(key) else { return nil }
        
        let decoder = try superDecoder(forKey: key)
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(type) {
            return value
        } else if let stringValue = try? container.decode(String.self) {
            return Float(stringValue)
        }
        return nil
    }
    
    public func decodeIfPresent(_ type: Int.Type, forKey key: K) throws -> Int? {
        
        guard contains(key) else { return nil }
        
        let decoder = try superDecoder(forKey: key)
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(type) {
            return value
        } else if let stringValue = try? container.decode(String.self) {
            return Int(stringValue)
        }
        return nil
    }
    
    public func decodeIfPresent(_ type: UInt.Type, forKey key: K) throws -> UInt? {
        
        guard contains(key) else { return nil }
        
        let decoder = try superDecoder(forKey: key)
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(type) {
            return value
        } else if let stringValue = try? container.decode(String.self) {
            return UInt(stringValue)
        }
        return nil
    }
    
    public func decodeIfPresent<T>(_ type: T.Type, forKey key: K) throws -> T? where T : Decodable {
        
        if let stringValue = try? decode(String.self, forKey: key) {
            return stringValue as? T
        } else if let boolValue = try? decode(Bool.self, forKey: key) {
            return boolValue as? T
        } else if let intValue = try? decode(Int.self, forKey: key) {
            return intValue as? T
        } else if let uintValue = try? decode(UInt.self, forKey: key) {
            return uintValue as? T
        } else if let doubleValue = try? decode(Double.self, forKey: key) {
            return doubleValue as? T
        } else if let floatValue = try? decode(Float.self, forKey: key) {
            return floatValue as? T
        }
        
        guard contains(key) else { return nil }
        
        let decoder = try superDecoder(forKey: key)
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(type) {
            return value
        } else if let nestedUnkeyedContainer = try? nestedUnkeyedContainer(forKey: key) {
            let mirror = Mirror(reflecting: nestedUnkeyedContainer)
            var array: [Any]? = []
            mirror.children.forEach({
                if $0.label == "container" {
                    array = $0.value as? [Any]
                    return
                }
            })
            return array?.map({ String(anyValue: $0) }) as? T
        }
        
        return nil
    }
}

fileprivate extension String {
    
    init(anyValue: Any) {
        if let value = anyValue as? String {
            self = value
        } else if let value = anyValue as? Int {
            self = String(value)
        } else if let value = anyValue as? Double {
            self = String(value)
        } else if let value = anyValue as? Bool {
            self = String(value)
        } else {
            self = ""
        }
    }
}
