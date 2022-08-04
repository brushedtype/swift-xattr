//
//  ExtendedAttributes.swift
//  
//
//  Created by Edward Wellbrook on 14/07/2022.
//

import Foundation

extension URL {

    /// List extended attributes for file URL
    public func extendedAttributes() throws -> Set<ExtendedAttribute> {
        guard self.isFileURL else {
            throw XAttrError.unsupportedURL
        }

        let path = self.path
        let opts: Int32 = 0

        let maxCapacity = 1<<16
        let list = UnsafeMutablePointer<CChar>.allocate(capacity: maxCapacity)
        defer {
            list.deallocate()
        }

        let sizeOfList = maxCapacity * MemoryLayout<CChar>.size

        let len = listxattr(path, list, sizeOfList, opts)

        if len == -1 {
            throw XAttrError(errno: errno)
        }

        if len == 0 {
            return []
        }

        let chars = Array<CChar>(copying: list, count: len)

        var attrs: [ExtendedAttribute] = []
        var currentAttr: [Character] = []

        for char in chars {
            if char == 0 {
                if let attr = ExtendedAttribute(String(currentAttr)) {
                    attrs.append(attr)
                }

                currentAttr.removeAll()
                continue
            }

            currentAttr.append(Character(UnicodeScalar(UInt8(char))))
        }

        return Set(attrs)
    }

    /// Retrieve extended attribute data for file URL
    public func extendedAttributeData(rawAttributeName: String) throws -> Data {
        guard self.isFileURL else {
            throw XAttrError.unsupportedURL
        }

        let opts: Int32 = 0

        let maxCapacity = 1<<8
        let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: maxCapacity)
        defer {
            bytes.deallocate()
        }

        let len = getxattr(self.path, rawAttributeName, bytes, maxCapacity, 0, opts)

        if len == -1 {
            throw XAttrError(errno: errno)
        }

        if len == 0 {
            return Data()
        }

        return Data(bytes: bytes, count: len)
    }

    public func setExtendedAttributeData(_ data: Data, attributeName: String, flags: ExtendedAttribute.Flags) throws {
        guard let attrName = xattr_name_with_flags(attributeName, flags.rawValue) else {
            throw XAttrError(errno: errno)
        }
        defer {
            attrName.deallocate()
        }

        try setExtendedAttributeData(data, rawAttributeName: String(cString: attrName))
    }

    public func setExtendedAttributeData(_ data: Data, rawAttributeName: String) throws {
        guard rawAttributeName.utf8.count < XATTR_MAXNAMELEN else {
            throw XAttrError.nameTooLong
        }

        guard self.isFileURL else {
            throw XAttrError.unsupportedURL
        }

        let opts: Int32 = 0

        let result: Int32 = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            return setxattr(self.path, rawAttributeName, ptr.baseAddress, data.count, 0, opts)
        }

        if result == -1 {
            throw XAttrError(errno: errno)
        }
    }

    public func removeExtendedAttribute(rawAttributeName: String) throws {
        guard self.isFileURL else {
            throw XAttrError.unsupportedURL
        }

        let opts: Int32 = 0

        let result: Int32 = removexattr(self.path, rawAttributeName, opts)

        if result == -1 {
            throw XAttrError(errno: errno)
        }
    }

}
