//
//  CFQError.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/18.
//

import Foundation

enum CFQError: Error {
    case emptyResponseError
    case requestTimeoutError
    case invalidResponseError(response: String)
}
