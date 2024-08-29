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
        
        bindQQ = await CFQUserServer.fetchUserOption(authToken: authToken, param: "bindQQ")
        forwardToFish = await CFQUserServer.fetchUserOption(authToken: authToken, param: "forwarding_fish") == "1"
        forwardToLxns = await CFQUserServer.fetchUserOption(authToken: authToken, param: "forwarding_lxns") == "1"
        rateLimiting = await CFQUserServer.fetchUserOption(authToken: authToken, param: "rate_limiting") == "1"
        maimaiFavList = await CFQUserServer.fetchUserOption(authToken: authToken, param: "maimai_fav_list")
        chunithmFavList = await CFQUserServer.fetchUserOption(authToken: authToken, param: "chunithm_fav_list")
        
        do {
            fishToken = try await CFQFishServer.fetchToken(authToken: authToken)
        } catch {
            print("Failed to fetch fish token from server.")
        }
    }
}
