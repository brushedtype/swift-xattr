//
//  Array+CopyArrayPointer.swift
//  
//
//  Created by Edward Wellbrook on 15/07/2022.
//

import Foundation

extension Array {

    init(copying ptrArr: UnsafeMutablePointer<Element>, count: Int) {
        let stride = MemoryLayout<Element>.stride

        self.init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0..<count {
                buffer[i] = ptrArr.advanced(by: stride * i).pointee
            }
            initializedCount = count
        }
    }

}
