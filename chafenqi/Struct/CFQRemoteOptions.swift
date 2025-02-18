//
//  CFQRemoteOptions.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/08/29.
//

import Foundation

class CFQRemoteOptions {
    var authToken: String = ""
    
    var bindQQ: String = ""
    var fishToken: String = ""
    var forwardToFish: Bool = false
    var forwardToLxns: Bool = false
    var rateLimiting: Bool = false
    var maimaiFavList: String = ""
    var chunithmFavList: String = ""
    
    func sync(authToken: String) async {
        self.authToken = authToken
        
        bindQQ = await CFQUserServer.getBindQQ(authToken: authToken)
        forwardToFish = await CFQUserServer.fetchUserOption(authToken: authToken, param: "forwarding_fish") == "true"
        forwardToLxns = await CFQUserServer.fetchUserOption(authToken: authToken, param: "forwarding_lxns") == "true"
        rateLimiting = await CFQUserServer.fetchUserOption(authToken: authToken, param: "rate_limiting") == "true"
        maimaiFavList = await CFQUserServer.fetchUserOption(authToken: authToken, param: "maimai_fav_list")
        chunithmFavList = await CFQUserServer.fetchUserOption(authToken: authToken, param: "chunithm_fav_list")
        fishToken = await CFQUserServer.fetchUserOption(authToken: authToken, param: "fish_token")
    }
}
