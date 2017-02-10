import Foundation

/// Protocol for object that can be created from json
public protocol JSONConvertible {
    init(value: Any?) throws
}

/// Protocol for object that can be converted to json
public protocol JSONRepresentable {
    var jsonValue: Any { get }
}

// MARK: - JSONConvertible

extension String: JSONConvertible {
    public init(value: Any?) throws {
        self = try value.string()
    }
}

extension Array where Element: JSONConvertible {
    
    /// Will filter out items that were failed to initialise.
    /// - throws : JSONError.InvalidKeyPathType if value is not array
    public init(value: Any?) throws {
        self = try value.array().flatMap({ try? Element(value: $0) })
    }
}

extension Dictionary where Key: JSONConvertible {
    
    public init(value: Any?, map: (Any?) throws -> (Value?)) throws {
        self = try value.object()
            .reduce([Key: Value]()) { (reduced, element) -> [Key: Value] in
                let key = try Key(value: element.0)
                let value = try map(element.1)
                var reduced = reduced
                reduced[key] = value
                return reduced
            }
    }

}

public enum Either<T: JSONConvertible, E: Error & JSONConvertible>: JSONConvertible {
    case data(T)
    case error(E)
    
    public var data: T? {
        if case let .data(data) = self { return data } else { return nil }
    }
    
    public var error: E? {
        if case let .error(error) = self { return error } else { return nil }
    }
    
    public init(value: Any?) throws {
        do {
            self = try .data(T(value: value))
        } catch {
            do {
                self = try .error(E(value: value))
            } catch _ {
                throw error
            }
        }
    }
}

// MARK: Optional subscripting

extension Optional {
    
    /// If value is array will get it's item by index
    public subscript(index index: Int) -> Any? {
        let array = self as? [Any]
        return array?[safe: index]
    }
    
    /// If value is object will get it's item by key
    public subscript(keyPath keyPath: String) -> Any? {
        let object = self as? [String: Any]
        return object?[keyPath]
    }
    
    /// Analog of `valueForKeyPath:` in NSDictionary
    /// Key paths can be strings or numeric strings.
    /// If key is string and value is dictionary will get value by this key.
    /// If key is numeric string and value is array will get it's item by index
    public subscript(keyPaths: String...) -> Any? {
        return self.keyPaths(normalize(keyPaths))
    }
    
    fileprivate func keyPaths(_ keyPaths: [String]) -> Any? {
        guard !keyPaths.isEmpty else {
            return self
        }
        
        let keyPath = keyPaths.first!
        let value: Any?
        
        if let index = Int(keyPath) {
            value = self[index: index]
        } else {
            value = self[keyPath: keyPath]
        }

        return value.keyPaths(Array(keyPaths.suffix(from: 1)))
    }
}

// MARK: Optional throwing getters

extension Optional {
    
    /// Gets generic value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to generic type
    public func get<T>(_ keyPaths: String...) throws -> T {
        return try get({ $0 as? T }, keyPaths: keyPaths)
    }

    /// Gets generic value by key paths array using provided getter closure
    /// - throws : JSONError.InvalidKeyPathType if getter returns nil
    public func get<T>(_ getter: (Any?) throws -> T?, keyPaths: [String]) throws -> T {
        let keyPaths = normalize(keyPaths)
        let keyPathValue = self.keyPaths(keyPaths)
        guard let _ = keyPathValue else {
            throw JSONError.noData(keyPaths: keyPaths, expectedType: String(describing: T.self), value: nil)
        }
        guard let value = try getter(keyPathValue) else {
            throw JSONError.invalidType(keyPaths: keyPaths, expectedType: String(describing: T.self), value: self)
        }
        return value
    }

    /// Gets string value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to string
    public func string(_ keyPaths: String..., trimming set: CharacterSet = CharacterSet.whitespaces) throws -> Swift.String {
        return try get({ $0 as? String }, keyPaths: keyPaths).trimmingCharacters(in: set)
    }
    
    public func string(_ keyPaths: String..., matching pattern: String) throws -> [String] {
        return try get({ $0 as? String }, keyPaths: keyPaths).match(pattern)
    }
    
    /// Gets double value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to double
    public func double(_ keyPaths: String...) throws -> Swift.Double {
        return try get({ $0 as? Double ?? ($0 as? NSNumber)?.doubleValue ?? ($0 as? String).flatMap(Double.init) }, keyPaths: keyPaths)
    }
    
    /// Gets float value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to float
    public func float(_ keyPaths: String...) throws -> Swift.Float {
        return try get({ $0 as? Float ?? ($0 as? NSNumber)?.floatValue ?? ($0 as? String).flatMap(Float.init) }, keyPaths: keyPaths)
    }
    
    /// Gets int value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to int
    public func int(_ keyPaths: String...) throws -> Swift.Int {
        return try get({ ($0 as? Int) ?? ($0 as? NSNumber)?.intValue ?? ($0 as? String).flatMap({ Int($0) }) }, keyPaths: keyPaths)
    }
    
    /// Gets bool value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to bool
    public func bool(_ keyPaths: String...) throws -> Swift.Bool {
        return try get({ $0 as? Bool ?? ($0 as? NSNumber)?.boolValue ?? ($0 as? String).flatMap(Bool.init)  }, keyPaths: keyPaths)
    }
    
    /// Gets array value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to array
    public func array(_ keyPaths: String...) throws -> [Any] {
        return try get({ $0 as? [Any] }, keyPaths: keyPaths)
    }
    
    /// Gets array of generic type items value by key paths.
    /// - returns : array of generic type items. Items that can not be converted to generic type are filtered out.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to array
    public func array<T>(_ keyPaths: String...) throws -> [T] {
        return try get({ ($0 as? [Any])?.flatMap({ $0 as? T }) }, keyPaths: keyPaths)
    }
    
    /// Gets array of generic type items value by key paths.
    /// - returns : array of generic type items. Items that can not be converted to generic type are filtered out.
    /// - throws : 
    /// `JSONError.InvalidKeyPathType` if value at key path can not be converted to array;\
    /// `JSONError.InvalidEmptyArray` if resulting array is empty
    public func notEmptyArray<T>(_ keyPaths: String...) throws -> [T] {
        let array = try get({ ($0 as? [Any])?.flatMap({ $0 as? T }) }, keyPaths: keyPaths)
        guard !array.isEmpty else {
            throw JSONError.invalidEmptyArray(keyPaths: normalize(keyPaths), expectedType: String(describing: T.self), value: array)
        }
        return array
    }
    
    /// Gets array of generic type items value by key paths.
    /// - returns : array of generic type items. Items that can not be initialised are filtered out.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to array
    public func array<T: JSONConvertible>(_ keyPaths: String...) throws -> [T] {
        return try get({ try [T](value: $0) }, keyPaths: keyPaths)
    }

    /// Gets array of generic type items value by key paths.
    /// - returns : array of generic type items. Items that can not be initialised are filtered out.
    /// - throws :
    /// `JSONError.InvalidKeyPathType` if value at key path can not be converted to array;\
    /// `JSONError.InvalidEmptyArray` if resulting array is empty
    public func notEmptyArray<T: JSONConvertible>(_ keyPaths: String...) throws -> [T] {
        let array = try get({ try [T](value: $0) }, keyPaths: keyPaths)
        guard !array.isEmpty else {
            throw JSONError.invalidEmptyArray(keyPaths: normalize(keyPaths), expectedType: String(describing: T.self), value: array)
        }
        return array
    }
    
    /// Gets string-key dictionary of generic type items by key paths.
    /// - returns : string-key dictionary of generic type items. Items that can not be initialised are filtered out
    /// - throws :
    /// `JSONError.InvalidKeyPathType` if value at key path can not be converted to array;
    public func dictionary<T: JSONConvertible>(_ keyPaths: String...) throws -> [String: T] {
        return try get({ try [String: T](value: $0, map: { try T(value: $0) }) }, keyPaths: keyPaths)
    }

    public func dictionary<T>(_ keyPaths: String..., map: (Any?) throws -> (T?)) throws -> [String: T] {
        return try get({ try [String: T](value: $0, map: map) }, keyPaths: keyPaths)
    }

    /// Gets JSON object  by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to JSON object
    public func object(_ keyPaths: String...) throws -> [String: Any] {
        return try get({ $0 as? [String: Any] }, keyPaths: keyPaths)
    }
    
    /// Gets value of generic type that can be initialised from JSON value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if failed to initialised generic type with value by key paths
    public func object<T: JSONConvertible>(_ keyPaths: String...) throws -> T {
        let value = try get({ $0 }, keyPaths: keyPaths)
        return try T(value: value)
    }
    
}

// MARK: Non-standard types

extension Optional {
    
    /// Gets url value by key paths.
    /// - throws : JSONError.InvalidKeyPathType if value at key path can not be converted to url
    public func url(_ keyPaths: String...) throws -> URL {
        return try get({ ($0 as? String).flatMap(URL.init(string:)) }, keyPaths: keyPaths)
    }
    
    /// Gets date by key paths using provided date formatter
    /// - throws : JSONError.InvalidKeyPathType if value at key path is not a string or date formatter fails to convert it to date
    public func date(_ keyPaths: String..., formatter: DateFormatter) throws -> Date {
        return try get({ ($0 as? String).flatMap(formatter.date(from:)) }, keyPaths: keyPaths)
    }

    public func currency(_ keyPaths: String...) throws -> Float {
        return try get({ ($0 as? Float) ?? ($0 as? NSNumber)?.floatValue ?? ($0 as? String).flatMap({ Float($0) }) }, keyPaths: keyPaths) / 100
    }

    /// Gets generic value that can be represented with raw value by key paths
    /// - throws : JSONError.InvalidKeyPathType if value can not be converted to `T.RawValue` type
    public func raw<T: RawRepresentable>(_ keyPaths: String...) throws -> T? {
        return try get({ ($0 as? T.RawValue).flatMap(T.init) }, keyPaths: keyPaths)
    }

}

/// Coverts array of key paths to proper key path: ["items.0.recipe", "name"] -> ["items", "0", "recipe", "name"]
private func normalize(_ keyPaths: [String]) -> [String] {
    return keyPaths.flatMap({ $0.components(separatedBy: ".") })
}

extension Bool {
    public init?(_ string: String) {
        switch string.lowercased() {
        case "1", "true":
            self = true
        case "0", "false":
            self = false
        default:
            return nil
        }
    }
}

extension Collection where Self.Index: Comparable {
    public subscript(safe index: Index) -> Iterator.Element? {
        return startIndex..<endIndex ~= index ? self[index] : nil
    }
}

extension String {
    public func match(_ pattern: String) throws -> [String] {
        let expr = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSRange(location: 0, length: characters.count)
        let result = expr.firstMatch(in: self, options: [], range: range)
        return result?.allRanges.flatMap({ self[range: $0] }) ?? []
    }
    
    subscript(range range: NSRange) -> String? {
        if NSMaxRange(range) <= self.characters.count {
            return (self as NSString).substring(with: range)
        }
        return nil
    }
}

extension NSTextCheckingResult {
    var allRanges: [NSRange] {
        return (0..<numberOfRanges).map(rangeAt)
    }
}

extension Optional {
    
    ///Scans int in a string
    public func intString(_ keyPaths: String...) throws -> Int {
        let string = try self.get({ $0 as? String }, keyPaths: keyPaths)
        let scanner = Scanner(string: string)
        var number: Int = 0
        if scanner.scanInt(&number) {
            return number
        } else {
            throw JSONError.invalidData(keyPaths: keyPaths, expectedType: String(describing: Int.self), value: self)
        }
    }
    
}


public extension CustomNSError where Self: LocalizedError {
    
    public var errorUserInfo: [String : Any] {
        var result = [String: Any]()
        if let description = errorDescription {
            result[NSLocalizedDescriptionKey] = description
        }
        
        if let reason = failureReason {
            result[NSLocalizedFailureReasonErrorKey] = reason
        }
        
        if let suggestion = recoverySuggestion {
            result[NSLocalizedRecoverySuggestionErrorKey] = suggestion
        }
        
        if let helpAnchor = helpAnchor {
            result[NSHelpAnchorErrorKey] = helpAnchor
        }
        return result
    }
    
}

public enum EntityError: CustomNSError {
    //Throw this error when trying to perform invalid operation on the entity
    case invalidOperation(operationDescription: String)
    
    public enum Code: Int {
        case invalidOperation
    }
    
    public var errorUserInfo: [String: Any] {
        switch self {
        case let .invalidOperation(operationDescription):
            return [
                NSLocalizedDescriptionKey: "Invalid entity operation.",
                NSLocalizedFailureReasonErrorKey: operationDescription
            ]
        }
    }
    
    public var errorCode: Int {
        switch self {
        case .invalidOperation:
            return Code.invalidOperation.rawValue
        }
    }
    
    public init?(error: Error) {
        if error is EntityError { self = error as! EntityError; return; }
        let error = error as NSError
        guard error.domain == EntityError.errorDomain else { return nil }
        
        switch Code(rawValue: error.code) {
        case .invalidOperation?:
            self = .invalidOperation(operationDescription: error.userInfo[NSLocalizedFailureReasonErrorKey] as? String ?? "")
        case nil:
            return nil
        }
    }
}

public enum JSONError: CustomNSError {
    
    case invalidType(keyPaths: [String], expectedType: String, value: Any?)
    case invalidData(keyPaths: [String], expectedType: String, value: Any?)
    case invalidEmptyArray(keyPaths: [String], expectedType: String, value: Any?)
    case noData(keyPaths: [String], expectedType: String, value: Any?)
    case unknown(NSError?, expectedType: String, value: Any?)
    
    public enum Code: Int {
        case invalidType
        case invalidData
        case invalidEmptyArray
        case noData
        case unknown
    }
    
    public enum UserInfoKey {
        public static let jsonValue     = "value"
        public static let keyPaths      = "keyPaths"
        public static let expectedType  = "expectedType"
    }
    
    public var errorUserInfo: [String: Any] {
        let reason: String
        let invalidKeyPaths: [String]
        let invalidValue: Any?
        let expectedType: String
        var underlyingError: NSError? = nil
        
        switch self {
        case let .invalidType(keyPaths, type, value):
            reason = "Value for key \"\(keyPaths.joined(separator: "."))\" is not \(type)."
            invalidValue = value
            invalidKeyPaths = keyPaths
            expectedType = type
        case let .invalidData(keyPaths, type, value):
            reason = "Value for key \"\(keyPaths.joined(separator: "."))\" is invalid."
            invalidValue = value
            invalidKeyPaths = keyPaths
            expectedType = type
        case let .invalidEmptyArray(keyPaths, type, value):
            reason = "Value for key \"\(keyPaths.joined(separator: "."))\" is empty array. Not empty array of \(type) expected."
            invalidValue = value
            invalidKeyPaths = keyPaths
            expectedType = type
        case let .noData(keyPaths, type, value):
            reason = "No value for key \"\(keyPaths.joined(separator: "."))\""
            invalidValue = value
            invalidKeyPaths = keyPaths
            expectedType = type
        case let .unknown(error, type, value):
            reason = error?.description ?? "Unknown error"
            invalidKeyPaths = []
            invalidValue = value
            expectedType = type
            underlyingError = error
        }
        
        var payload: [String: Any] = [
            NSLocalizedFailureReasonErrorKey: reason,
            JSONError.UserInfoKey.keyPaths: invalidKeyPaths,
            JSONError.UserInfoKey.expectedType: expectedType
        ]
        payload[JSONError.UserInfoKey.jsonValue] = invalidValue
        payload[NSUnderlyingErrorKey] = underlyingError
        return payload
    }
    
    public var errorCode: Int {
        switch self {
        case .invalidType:
            return Code.invalidType.rawValue
        case .invalidData:
            return Code.invalidData.rawValue
        case .invalidEmptyArray:
            return Code.invalidEmptyArray.rawValue
        case .noData:
            return Code.noData.rawValue
        case .unknown:
            return Code.unknown.rawValue
        }
    }
    
    public init?(error: Error) {
        if error is JSONError { self = error as! JSONError; return; }
        let error = error as NSError
        guard error.domain == JSONError.errorDomain else { return nil }
        guard let expectedType = error.userInfo[JSONError.UserInfoKey.expectedType] as? String else { return nil }
        
        let keyPaths = (error.userInfo[JSONError.UserInfoKey.keyPaths] as? [String]) ?? []
        let invalidValue = error.userInfo[JSONError.UserInfoKey.jsonValue]
        
        switch Code(rawValue: error.code) {
        case .invalidType?:
            self = .invalidType(keyPaths: keyPaths, expectedType: expectedType, value: invalidValue)
        case .invalidData?:
            self = .invalidData(keyPaths: keyPaths, expectedType: expectedType, value: invalidValue)
        case .invalidEmptyArray?:
            self = .invalidEmptyArray(keyPaths: keyPaths, expectedType: expectedType, value: invalidValue)
        case .noData?:
            self = .noData(keyPaths: keyPaths, expectedType: expectedType, value: invalidValue)
        case .unknown?:
            self = .unknown(error.userInfo[NSUnderlyingErrorKey] as? NSError, expectedType: expectedType, value: invalidValue)
        case nil:
            return nil
        }
    }
    
}

extension Optional {
    
    var desc: String {
        switch self {
        case let .some(wrapped):
            return "\(wrapped)"
        case .none:
            return "nil"
        }
    }
    
}

