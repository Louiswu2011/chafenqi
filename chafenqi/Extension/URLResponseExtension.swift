//
//  URLResponseExtension.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/7.
//

import Foundation

extension URLResponse {
    func statusCode() -> Int {
        let httpRespnse = self as! HTTPURLResponse
        return httpRespnse.statusCode
    }
}
