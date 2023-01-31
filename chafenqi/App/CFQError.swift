//
//  CFQError.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/18.
//

import Foundation

enum CFQError: Error {
    case AuthenticationFailedError
    case IOError(file: String)
    case unsupportedError(reason: String)
    case emptyResponseError
    case requestTimeoutError
    case invalidResponseError(response: String)
}
