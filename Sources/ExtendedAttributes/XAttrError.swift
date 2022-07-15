//
//  XAttrError.swift
//  
//
//  Created by Edward Wellbrook on 15/07/2022.
//

import Foundation

enum XAttrError: Error {
    case unsupportedURL
    case unknownError
    case nameTooLong
    case memoryAllocationFailed
}

extension XAttrError {
    init(errno: errno_t) {
        switch errno {
        case ENAMETOOLONG:
            self = .nameTooLong
        case ENOMEM:
            self = .memoryAllocationFailed
        default:
            self = .unknownError
        }
    }
}
