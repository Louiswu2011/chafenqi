//
//  ProberService.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/18.
//

import Foundation
import Moya

enum ProberService {
    case getSongInfo
    case getUserInfoById(identifier: String)
    case getUserInfoByName(identifier: String)
}

extension ProberService: TargetType {
    var baseURL: URL { URL(string: "https://www.diving-fish.com/api/chunithmprober")! }
    var path: String {
        switch self {
        case .getSongInfo:
            return "/music_data"
        case .getUserInfoById(identifier: _), .getUserInfoByName(identifier: _):
            return "/query/player"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSongInfo:
            return .get
        case .getUserInfoByName(identifier: _), .getUserInfoById(identifier: _):
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getSongInfo:
            return .requestPlain
        case let .getUserInfoById(identifier: id):
            return .requestParameters(parameters: ["qq": id], encoding: JSONEncoding.default)
        case let .getUserInfoByName(identifier: username):
            return .requestParameters(parameters: ["username": username], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json", "Accept": "application/json"]
    }
}
