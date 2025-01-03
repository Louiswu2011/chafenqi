//
//  CFQTeamServer.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct CFQTeamServer {
    static let session = URLSession(configuration: .default)
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    
    static private func fetchFromServer(
        method: String,
        path: String,
        payload: Data? = nil,
        queries: [URLQueryItem] = [],
        token: String? = nil
    ) async throws -> (Data, URLResponse) {
        var url = URLComponents(string: CFQServer.serverAddress + "api/team/" + path)!
        if !queries.isEmpty {
            url.queryItems = queries
        }
        var request = URLRequest(url: url.url!)
        request.httpMethod = method
        request
            .setValue(
                "application/json; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
        if let payload = payload {
            request
                .setValue(
                    "\(payload.count)",
                    forHTTPHeaderField: "Content-Length"
                )
            request.httpBody = payload
        }
        if let token = token {
            request
                .setValue(
                    "bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                )
        }
        let (data, response) = try await session.data(for: request)
        print("Response from \(path)")
        print("Status Code: \(response.statusCode())")
        print("Response Body Length: \(data.count)")
        return (data, response)
    }
    
    static private func fetchFromTeam(
        token: String,
        game: Int,
        teamId: Int,
        method: String,
        path: String,
        payload: Data? = nil,
        queries: [URLQueryItem] = []
    ) async throws -> (Data, URLResponse) {
        return try await fetchFromServer(
            method: method,
            path: "\(game.gameString())/\(teamId)/\(path)",
            payload: payload,
            queries: queries,
            token: token
        )
    }
    
    static func fetchCurrentTeam(
        authToken: String,
        game: Int
    ) async -> Int? {
        do {
            let (data, _) = try await fetchFromServer(
                method: "GET",
                path: "\(game.gameString())/current",
                token: authToken
            )
            
            return Int(String(data: data, encoding: .utf8) ?? "")
        } catch {
            print("Failed to fetch current team: \(error)")
            return nil
        }
    }
    
    static func fetchTeamInfo(
        authToken: String,
        game: Int,
        teamId: Int
    ) async -> TeamInfo? {
        do {
            let (data, _) = try await fetchFromServer(
                method: "GET",
                path: "\(game.gameString())/\(teamId)",
                token: authToken
            )
            return try decoder.decode(TeamInfo.self, from: data)
        } catch {
            print("Failed to fetch team info: \(error)")
            return nil
        }
    }
    
    static func fetchAllTeamInfos(
        authToken: String,
        game: Int
    ) async -> [TeamBasicInfo] {
        do {
            let (data, _) = try await fetchFromServer(method: "GET", path: "\(game.gameString())", token: authToken)
            return try decoder.decode(Array<TeamBasicInfo>.self, from: data)
        } catch {
            print("Failed to fetch all game \(game) teams: \(error)")
            return []
        }
    }
    
    static func createTeam(
        authToken: String,
        payload: TeamCreatePayload
    ) async -> String {
        do {
            let (data, _) = try await fetchFromServer(
                method: "POST",
                path: "\(payload.game.gameString())/create",
                payload: try encoder.encode(payload),
                token: authToken
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to create team: \(error)")
            return "未知错误，请联系开发者。"
        }
    }
    
    static func applyForTeam(
        authToken: String,
        game: Int,
        teamId: Int,
        message: String
    ) async -> String {
        do {
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "apply"
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to apply for team: \(error)")
            return "未知错误，请联系开发者。"
        }
    }
    
    static func leaveTeam(
        authToken: String,
        game: Int,
        teamId: Int
    ) async -> String {
        do {
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "DELETE",
                path: "leave"
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to leave team: \(error)")
            return "未知错误，请联系开发者。"
        }
    }
    
    static func getTeamBulletinBoard(
        authToken: String,
        game: Int,
        teamId: Int
    ) async -> [TeamBulletinBoardEntry]? {
        do {
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "GET",
                path: "bulletin"
            )
            return try decoder.decode([TeamBulletinBoardEntry].self, from: data)
        } catch {
            print("Failed to get team bulletin board: \(error)")
            return nil
        }
    }
    
    static func addTeamBulletinBoardEntry(
        authToken: String,
        game: Int,
        teamId: Int,
        message: String
    ) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["message": message]
            )
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "bulletin",
                payload: payload
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to add team bulletin board entry: \(error)")
            return "未知错误，请联系开发者：\(error)"
        }
    }
    
    static func deleteTeamBulletinBoardEntry(
        authToken: String,
        game: Int,
        teamId: Int,
        entryId: Int
    ) async -> String {
        do {
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "DELETE",
                path: "bulletin",
                queries: [URLQueryItem(name: "id", value: String(entryId))]
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to delete team bulletin board entry: \(error)")
            return "未知错误，请联系开发者：\(error)"
        }
    }
    
    static func adminAcceptMember(
        authToken: String,
        game: Int,
        teamId: Int,
        pendingMemberId: Int
    ) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["userId": pendingMemberId]
            )
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/member/accept",
                payload: payload
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to accept member: \(error)")
            return "未知错误，请联系开发者：\(error)"
        }
    }
    
    static func adminRejectMember(
        authToken: String,
        game: Int,
        teamId: Int,
        pendingMemberId: Int
    ) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["userId": pendingMemberId]
            )
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/member/reject",
                payload: payload
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to reject member: \(error)")
            return "未知错误，请联系开发者：\(error)"
        }
    }
    
    static func adminKickMember(
        authToken: String,
        game: Int,
        teamId: Int,
        memberId: Int
    ) async -> String {
        do {
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "DELETE",
                path: "admin/member/kick",
                queries: [URLQueryItem(name: "userId", value: String(memberId))]
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to kick member: \(error)")
            return "未知错误，请联系开发者：\(error)"
        }
    }
    
    static func adminTransferOwnership(
        authToken: String,
        game: Int,
        teamId: Int,
        newLeaderUserId: Int
    ) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["newLeaderUserId": newLeaderUserId]
            )
            let (data, _) = try await fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "PUT",
                path: "admin/member/transfer",
                payload: payload
            )
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to transfer ownership: \(error)")
            return "未知错误，请联系开发者：\(error)"
        }
    }
    
    static func adminRotateTeamCode(authToken: String, game: Int, teamId: Int) async -> Bool {
        do {
            let (_, response) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/update/code"
            )
            return response.statusCode() == 200
        } catch {
            print("CFQTeamServer: Failed to rotate team code: \(error)")
            return false
        }
    }

    static func adminUpdateTeamName(authToken: String, game: Int, teamId: Int, newName: String) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["displayName": newName],
                options: []
            )
            let (data, _) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/update/name",
                payload: payload
            )
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("CFQTeamServer: Failed to update team name: \(error)")
            return "未知错误，请联系开发者。"
        }
    }

    static func adminUpdateTeamStyle(authToken: String, game: Int, teamId: Int, newStyle: String) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["style": newStyle],
                options: []
            )
            let (data, _) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/update/style",
                payload: payload
            )
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("CFQTeamServer: Failed to update team style: \(error)")
            return "未知错误，请联系开发者。"
        }
    }

    static func adminUpdateTeamRemarks(authToken: String, game: Int, teamId: Int, newRemarks: String) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["remarks": newRemarks],
                options: []
            )
            let (data, _) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/update/remarks",
                payload: payload
            )
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("CFQTeamServer: Failed to update team remarks: \(error)")
            return "未知错误，请联系开发者。"
        }
    }

    static func adminUpdateTeamPromotable(authToken: String, game: Int, teamId: Int, promotable: Bool) async -> Bool {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["promotable": promotable],
                options: []
            )
            let (_, response) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/update/promotable",
                payload: payload
            )
            return response.statusCode() == 200
        } catch {
            print("CFQTeamServer: Failed to update team promotable: \(error)")
            return false
        }
    }

    static func adminUpdateTeamCourse(authToken: String, game: Int, teamId: Int, newCourse: TeamUpdateCoursePayload) async -> String {
        do {
            let payload = try encoder.encode(newCourse)
            let (data, _) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/update/course",
                payload: payload
            )
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("CFQTeamServer: Failed to update team course: \(error)")
            return "未知错误，请联系开发者。"
        }
    }

    static func adminSetPinnedMessage(authToken: String, game: Int, teamId: Int, pinnedMessageId: Int) async -> String {
        do {
            let payload = try JSONSerialization.data(
                withJSONObject: ["id": pinnedMessageId],
                options: []
            )
            let (_, response) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "POST",
                path: "admin/update/pinned",
                payload: payload
            )
            return response.statusCode() == 200 ? "" : "未知错误，请联系开发者。"
        } catch {
            print("CFQTeamServer: Failed to set pinned message: \(error)")
            return error.localizedDescription
        }
    }

    static func adminResetPinnedMessage(authToken: String, game: Int, teamId: Int) async -> String {
        do {
            let (_, response) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "DELETE",
                path: "admin/update/pinned"
            )
            return response.statusCode() == 200 ? "" : "未知错误，请联系开发者。"
        } catch {
            print("CFQTeamServer: Failed to reset pinned message: \(error)")
            return error.localizedDescription
        }
    }

    static func adminDisbandTeam(authToken: String, game: Int, teamId: Int) async -> Bool {
        do {
            let (_, response) = try await CFQTeamServer.fetchFromTeam(
                token: authToken,
                game: game,
                teamId: teamId,
                method: "DELETE",
                path: "admin/disband"
            )
            return response.statusCode() == 200
        } catch {
            print("CFQTeamServer: Failed to disband team: \(error)")
            return false
        }
    }
    
}

extension Int {
    func gameString() -> String {
        return if self == 0 { "chunithm" } else { "maimai" }
    }
}
