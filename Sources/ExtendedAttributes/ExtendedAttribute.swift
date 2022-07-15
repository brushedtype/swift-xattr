//
//  ExtendedAttribute.swift
//  
//
//  Created by Edward Wellbrook on 15/07/2022.
//

import Foundation

public struct ExtendedAttribute: Hashable {

    public let rawValue: String
    public let name: String
    public let flags: Flags

    init?(_ rawValue: String) {
        self.rawValue = rawValue

        guard let name = xattr_name_without_flags(rawValue) else {
            return nil
        }
        defer {
            name.deallocate()
        }
        self.name = String(cString: name)

        self.flags = Flags(rawValue: xattr_flags_from_name(rawValue))
    }

}

extension ExtendedAttribute {

    public struct Flags: OptionSet, Hashable {
        public let rawValue: xattr_flags_t

        public init(rawValue: xattr_flags_t) {
            self.rawValue = rawValue
        }

        public static let noExport         = Flags(rawValue: XATTR_FLAG_NO_EXPORT)
        public static let contentDependent = Flags(rawValue: XATTR_FLAG_CONTENT_DEPENDENT)
        public static let neverPreserve    = Flags(rawValue: XATTR_FLAG_NEVER_PRESERVE)
        public static let syncable         = Flags(rawValue: XATTR_FLAG_SYNCABLE)
    }

}

extension ExtendedAttribute.Flags: CustomStringConvertible {

    public var description: String {
        var flagComponents: [String] = []

        if self.contains(.noExport) {
            flagComponents.append("noExport")
        }
        if self.contains(.contentDependent) {
            flagComponents.append("contentDependent")
        }
        if self.contains(.neverPreserve) {
            flagComponents.append("neverPreserve")
        }
        if self.contains(.syncable) {
            flagComponents.append("syncable")
        }

        let flagRep = flagComponents.isEmpty ? "none" : flagComponents.joined(separator: ",")
        return "[\(flagRep)]"
    }

}
