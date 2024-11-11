//
//  CFQNUser.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/4.
//

import Foundation
import SwiftUI
import OneSignal
import FirebasePerformance
import FirebaseAnalytics

class CFQNUser: ObservableObject {
    @Published var didLogin = false
    
    var iOSMajorVersion = Int(UIDevice.current.systemVersion.split(separator: ".")[0])!
    
    @AppStorage("JWT") var jwtToken = ""
    @AppStorage("MaimaiCache") var maimaiCache = Data()
    @AppStorage("ChunithmCache") var chunithmCache = Data()
    @AppStorage("widgetCustomization") var widgetCustom = Data()
    
    @AppStorage("maimaiSongListVersion") var maimaiSongListVersion = 0
    @AppStorage("chunithmSongListVersion") var chunithmSongListVersion = 0
    
    @AppStorage("settingsRecentLogEntryCount") var entryCount = "30"
    @AppStorage("settingsChunithmCoverSource") var chunithmCoverSource = 1
    @AppStorage("settingsChunithmChartSource") var chunithmChartSource = 1
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsCurrentMode") var currentMode = 0
    @AppStorage("settingsChunithmPricePerTrack") var chuPricePerTrack = ""
    @AppStorage("settingsMaimaiPricePerTrack") var maiPricePerTrack = ""
    @AppStorage("settingsHomeArrangement") var homeArrangement = "最近动态|Rating分析|出勤记录"
    @AppStorage("settingsHomeShowDaysSinceLastPlayed") var showDaysSinceLastPlayed = false
    @AppStorage("settingsAutoRedirectToWeChat") var proxyAutoJump = false
    @AppStorage("settingsShouldPromptDFishLinking") var proxyShouldPromptLinking = true
    @AppStorage("settingsShouldPromptExpiredToken") var proxyShouldPromptExpiring = true
    @AppStorage("settingsShouldPromptTooHighVersion") var proxyShouldPromptManualProxy = true
    @AppStorage("settingsShowRefreshButton") var shouldShowRefreshButton = false
    @AppStorage("settingsAutoUpdateSongList") var shouldAutoUpdateSongList = true
    @AppStorage("settingsHomeNameplateTheme") var homeUseCurrentVersionTheme = true
    
    var maimai = Maimai()
    var chunithm = Chunithm()
    var data = CFQPersistentData()
    var remoteOptions = CFQRemoteOptions()
    
    var assertionFailedTried = false
    
    @AppStorage("CFQUsername") var username = ""
    
    var isPremium = false
    var premiumUntil: TimeInterval = 0
    
    @Published var loadPrompt = ""

    struct Maimai: Codable {
        struct Custom: Codable {
            var pastSlice: CFQMaimaiBestScoreEntries = []
            var currentSlice: CFQMaimaiBestScoreEntries = []
            var pastRating = 0
            var currentRating = 0
            var rawRating = 0
            
            var rankCounter = [0, 0, 0, 0, 0, 0, 0]
            var statusCounter = [0, 0, 0, 0, 0]
            
            var recommended: [CFQMaimai.RecentScoreEntry: String] = [:]
            var genreList: [String] = []
            var versionList: [String] = []
            
            var levelRecords = CFQMaimaiLevelRecords()
            var dayRecords: CFQMaimaiDayRecords = .init()
            
            var ratingRank = MaimaiRatingRank()
            var totalScoreRank = MaimaiTotalScoreRank()
            var totalPlayedRank = MaimaiTotalPlayedRank()
            var firstRank = MaimaiFirstRank()
            
            init() {}
            
            // MARK: Maimai Custom Init
            init(orig: CFQMaimaiBestScoreEntries, recent: CFQMaimaiRecentScoreEntries, list: [MaimaiSongData], delta: CFQMaimaiDeltaEntries) {
                guard (!orig.isEmpty && !recent.isEmpty) else { return }
                self.pastSlice = Array(orig.filter { entry in
                    return !entry.associatedSong!.basicInfo.isNew
                }.sorted { $0.rating > $1.rating }.prefix(35))
                self.currentSlice = Array(orig.filter { entry in
                    return entry.associatedSong!.basicInfo.isNew
                }.sorted { $0.rating > $1.rating }.prefix(15))
                self.pastRating = self.pastSlice.reduce(0) { orig, next in
                    orig + next.rating
                }
                self.currentRating = self.currentSlice.reduce(0) { orig, next in
                    orig + next.rating
                }
                self.rawRating = self.pastRating + self.currentRating
                
                var r = recent.prefix(30)
                if let max = (r.filter {
                    $0.fc == "applus"
                }.first) {
                    recommended[max] = "MAX"
                    r.removeAll { $0.timestamp == max.timestamp }
                }
                
                if let ap = (r.filter {
                    $0.fc == "ap"
                }.first) {
                    recommended[ap] = "AP"
                    r.removeAll { $0.timestamp == ap.timestamp }
                }
                if let fc = (r.filter {
                    $0.fc.hasPrefix("fc") || $0.fs.hasPrefix("fs")
                }.first) {
                    recommended[fc] = "FC"
                    r.removeAll { $0.timestamp == fc.timestamp }
                }
                let hs = r.sorted {
                    $0.score > $1.score
                }.first!
                recommended[hs] = "HS"
                let ro = r.sorted {
                    $0.timestamp > $1.timestamp
                }.first!
                recommended[ro] = "RO"
                if let nr = (r.filter {
                    $0.isNewRecord == 1
                }.sorted { $0.timestamp > $1.timestamp }.first) { recommended[nr] = "NR" }
                
                for entry in orig {
                    switch entry.score {
                    case 100.5...101:
                        rankCounter[0] += 1
                    case 100.0...100.4999:
                        rankCounter[1] += 1
                    case 99.5...99.9999:
                        rankCounter[2] += 1
                    case 99.0...99.4999:
                        rankCounter[3] += 1
                    case 98.0...98.9999:
                        rankCounter[4] += 1
                    case 97.0...97.9999:
                        rankCounter[5] += 1
                    default:
                        rankCounter[6] += 1
                    }
                    switch entry.fc {
                    case "app":
                        statusCounter[0] += 1
                    case "ap":
                        statusCounter[1] += 1
                    case "fcp":
                        statusCounter[2] += 1
                    case "fc":
                        statusCounter[3] += 1
                    default:
                        statusCounter[4] += 1
                    }
                }
                
                self.levelRecords = CFQMaimaiLevelRecords(songs: list, best: orig)
                self.dayRecords = CFQMaimaiDayRecords(recents: recent, deltas: delta)
                
                self.versionList = list.map { entry in entry.basicInfo.from }.unique
                self.genreList = list.map { entry in entry.basicInfo.genre }.unique

                print("[CFQNUser] Loaded maimai Custom Data.")
            }
        }
        
        var info: CFQMaimaiUserInfo = .empty
        var best: CFQMaimaiBestScoreEntries = []
        var recent: CFQMaimaiRecentScoreEntries = []
        var delta: CFQMaimaiDeltaEntries = []
        var extra: CFQMaimaiExtraEntry = .empty
        var custom: Custom = Custom()
        var isNotEmpty: Bool = false
        
        init(token: String) async throws {
            let server = CFQMaimaiServer(authToken: token)
            do {
                
                async let info = try server.fetchUserInfo()
                async let best = try server.fetchBestEntries()
                async let recent = try server.fetchRecentEntries()
                
                self.info = try await info
                self.best = try await best
                self.recent = try await recent
                isNotEmpty = true
            } catch {
                print("[CFQNUser] No maimai data from server.")
                print(String(describing: error))
            }
            do {
                self.delta = try await server.fetchDeltaEntries().reversed()
                self.extra = try await server.fetchExtraEntry()
            } catch CFQServerError.UserNotPremiumError {
                self.delta = []
                self.extra = .empty
                print("[CFQNUser] User is not premium, skipping maimai deltas/extras.")
            } catch {
                self.delta = []
                self.extra = .empty
                print(error)
                print("[CFQNUser] User is premium but maimai delta/extra info is missing, skipping...")
            }
        }
        
        init() {}
    }
    
    struct Chunithm: Codable {
        struct Custom: Codable {
            var b30Slice: CFQChunithmRatingEntries = []
            var r10Slice: CFQChunithmRatingEntries = []
            var candidateSlice: CFQChunithmRatingEntries = []
            var b30: Double = 0.0
            var r10: Double = 0.0
            var maxRating: Double = 0.0
            
            var recommended: [CFQChunithm.RecentScoreEntry: String] = [:]
            var genreList: [String] = []
            var versionList: [String] = []
            
            var levelRecords = CFQChunithmLevelRecords()
            var dayRecords: CFQChunithmDayRecords = .init()
            
            var ratingRank = ChunithmRatingRank()
            var totalScoreRank = ChunithmTotalScoreRank()
            var totalPlayedRank = ChunithmTotalPlayedRank()
            var firstRank = ChunithmFirstRank()
            
            init() {}
            
            // MARK: Chunithm Custom Init
            init(orig: CFQChunithmRatingEntries, recent: CFQChunithmRecentScoreEntries, best: CFQChunithmBestScoreEntries, list: [ChunithmMusicData], delta: CFQChunithmDeltaEntries) {
                guard !orig.isEmpty && !recent.isEmpty else { return }
                self.b30Slice = orig.filter {
                    $0.type == "best"
                }
                self.r10Slice = orig.filter {
                    $0.type == "recent"
                }
                self.candidateSlice = orig.filter {
                    $0.type == "candidate"
                }
                self.b30 = (self.b30Slice.reduce(0.0) { orig, next in
                    orig + next.rating
                } / 30.0).cut(remainingDigits: 2)
                self.r10 = (self.r10Slice.reduce(0.0) { orig, next in
                    orig + next.rating
                } / 10.0).cut(remainingDigits: 2)
                
                let b1 = self.b30Slice.sorted {
                    $0.rating > $1.rating
                }.first!
                self.maxRating = ((self.b30 * 30.0 + b1.rating * 10.0) / 40.0).cut(remainingDigits: 2)
                
                var r = recent.prefix(30)
                if let max = (r.filter {
                    $0.score == 1010000
                }.first) {
                    recommended[max] = "MAX"
                    r.removeAll { $0.timestamp == max.timestamp }
                }
                
                if let ap = (r.filter {
                    $0.fcombo == "alljustice"
                }.first) {
                    recommended[ap] = "AJ"
                    r.removeAll { $0.timestamp == ap.timestamp }
                }
                if let fc = (r.filter {
                    $0.fcombo.contains("fullcombo") || $0.fchain.contains("fullchain")
                }.first) {
                    recommended[fc] = "FC"
                    r.removeAll { $0.timestamp == fc.timestamp }
                }
                let hs = r.sorted {
                    $0.score > $1.score
                }.first!
                recommended[hs] = "HS"
                let ro = r.sorted {
                    $0.timestamp > $1.timestamp
                }.first!
                recommended[ro] = "RO"
                if let nr = (r.filter {
                    $0.isNewRecord == 1
                }.sorted { $0.timestamp > $1.timestamp }.first) { recommended[nr] = "NR" }
                
                levelRecords = CFQChunithmLevelRecords(songs: list, best: best)
                dayRecords = CFQChunithmDayRecords(recents: recent, deltas: delta)
                
                self.genreList = list.map { entry in entry.genre }.unique
                self.versionList = list.map { entry in entry.from }.unique
                
                print("[CFQNUser] Loaded chunithm Custom Data.")
            }
        }
        
        var info: CFQChunithmUserInfo = .empty
        var best: CFQChunithmBestScoreEntries = []
        var recent: CFQChunithmRecentScoreEntries = []
        var rating: CFQChunithmRatingEntries = []
        var delta: CFQChunithmDeltaEntries = []
        var extra: CFQChunithmExtraEntry = .empty
        var isNotEmpty: Bool = false
        var custom: Custom = Custom()
        
        init(token: String) async throws {
            let server = CFQChunithmServer(authToken: token)
            do {
                async let info = try server.fetchUserInfo()
                async let best = try server.fetchBestEntries()
                async let recent = try server.fetchRecentEntries()
                async let rating = try server.fetchRatingEntries()
                
                self.info = try await info
                self.best = try await best
                self.recent = try await recent
                self.rating = try await rating
                
                hideWorldsEnd()
                
                isNotEmpty = true
            } catch {
                print("[CFQNUser] No chunithm game data from server.")
                print(String(describing: error))
            }
            do {
                async let delta = try server.fetchDeltaEntries()
                async let extra = try server.fetchExtraEntries()
                
                self.delta = try await delta.sorted {
                    $0.createdAt.toDate()?.timeIntervalSince1970 ?? 0 > $1.createdAt.toDate()?.timeIntervalSince1970 ?? 0
                }
                self.extra = try await extra
            } catch CFQServerError.UserNotPremiumError {
                print("[CFQNUser] User is not premium, skipping chunithm extras.")
            } catch {
                self.delta = []
                self.extra = .empty
                print(error)
                print("[CFQNUser] User is premium but chunithm delta/extra info is missing, skipping...")
            }
        }
        
        init() {}
        
        mutating func hideWorldsEnd() {
            self.best.removeAll {
                $0.idx == "1"
            }
            self.recent.removeAll {
                $0.idx == "1"
            }
        }
    }
    
    init() {}
    
    func fetchUserData(token: String, username: String) async throws {
        publishLoadStatus("查询订阅状态...")
        self.isPremium = try await CFQUserServer.checkPremium(username: username)
        print("[CFQNUser] Acquired premium status: \(isPremium.description)")
        
        if self.isPremium {
            self.premiumUntil = try await CFQUserServer.checkPremiumExpireTime(username: username)
        }
        
        publishLoadStatus("获取舞萌DX数据...")
        self.maimai = try await Maimai(token: token)
        
        publishLoadStatus("获取中二节奏数据...")
        self.chunithm = try await Chunithm(token: token)
        print("[CFQNUser] Fetched User Data.")
        
        try await addAdditionalData(username: username)
        
        
        publishLoadStatus("更新本地缓存...")
        let maiCache = try JSONEncoder().encode(self.maimai)
        let chuCache = try JSONEncoder().encode(self.chunithm)
        
        DispatchQueue.main.async {
            self.maimaiCache = maiCache
            self.chunithmCache = chuCache
            print("[CFQNUser] Saved Data to Cache.")
        }
    }
    
    func filterAssociated() -> [String] {
        let maiDeleted = self.maimai.best.filter {
            $0.associatedSong == nil
        }.map {
            $0.title
        }
        self.maimai.best = self.maimai.best.filter {
            $0.associatedSong != nil
        }
        self.maimai.recent = self.maimai.recent.filter {
            $0.associatedSong != nil
        }
        
        let chuDeleted = self.chunithm.best.filter {
            $0.associatedSong == nil
        }.map {
            $0.title
        }
        self.chunithm.best = self.chunithm.best.filter {
            $0.associatedSong != nil
        }
        self.chunithm.recent = self.chunithm.recent.filter {
            $0.associatedSong != nil
        }
        self.chunithm.rating = self.chunithm.rating.filter {
            $0.associatedBestEntry?.associatedSong != nil
        }
        
        return (maiDeleted + chuDeleted).unique
    }
    
    func login(username: String, forceReload: Bool = false) async throws {
        let loginTrace = Performance.startTrace(name: "login")
        publishLoadStatus("检查持久化数据...")
        self.data = try await forceReload ? .forceRefresh() : .loadFromCacheOrRefresh(user: self)

        try await fetchUserData(token: self.jwtToken, username: username)
        
        OneSignal.setExternalUserId(username)
        Analytics.setUserID(username)
        
        print("[CFQNUser] Saved game data cache.")
        loginTrace?.stop()
    }
    
    func logout() {
        self.maimaiCache = Data()
        self.chunithmCache = Data()
        self.jwtToken = ""
        self.username = ""
        self.isPremium = false
        withAnimation {
            self.didLogin.toggle()
        }
        
        OneSignal.removeExternalUserId()
        Analytics.setUserID(nil)
    }
    
    func loadFromCache() async throws {
        let start = Date().timeIntervalSince1970
        let decoder = JSONDecoder()
        
        publishLoadStatus("查询订阅状态...")
        self.isPremium = try await CFQUserServer.checkPremium(username: self.username)
        print("[CFQNUser] Acquired premium status: \(isPremium.description)")
        
        if self.isPremium {
            self.premiumUntil = try await CFQUserServer.checkPremiumExpireTime(username: self.username)
        }
        
        publishLoadStatus("加载歌曲列表...")
        self.data = try await .loadFromCacheOrRefresh(user: self)
        self.maimai = try decoder.decode(Maimai.self, from: self.maimaiCache)
        self.chunithm = try decoder.decode(Chunithm.self, from: self.chunithmCache)
        print("[CFQNUser] Loaded user cache.")
        
        try await addAdditionalData(username: self.username)
        let end = Date().timeIntervalSince1970
        print("[CFQNUser] Loaded cache in \(end - start)s.")
    }
    
    func refresh() async throws {
        do {
            try await self.fetchUserData(token: self.jwtToken, username: self.username)
            print("[CFQNUser] Refreshed game data.")
        } catch CFQNUserError.AssociationError {
            if (!self.assertionFailedTried) {
                self.assertionFailedTried = true
                self.data = try await .forceRefresh()
                try await self.refresh()
                print("[CFQNUser] Tried to reload song list.")
            } else {
                let decoder = JSONDecoder()
                self.assertionFailedTried = false
                print("[CFQNUser] Assertion failed, rolling back.")
                self.maimai = try decoder.decode(Maimai.self, from: self.maimaiCache)
                self.chunithm = try decoder.decode(Chunithm.self, from: self.chunithmCache)
                try await addAdditionalData(username: self.username)
            }
        }
    }
    
    // MARK: Post-Init
    func addAdditionalData(username: String, skipCustomLoading: Bool = false) async throws {
        publishLoadStatus("关联歌曲信息...")
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                if (!self.data.maimai.songlist.isEmpty) {
                    if (!self.maimai.best.isEmpty) {
                        self.maimai.best = CFQMaimai.assignAssociated(songs: self.data.maimai.songlist, bests: self.maimai.best)
                    }
                    if (!self.maimai.recent.isEmpty) {
                        self.maimai.recent = CFQMaimai.assignAssociated(songs: self.data.maimai.songlist, recents: self.maimai.recent)
                    }
                }
            }
            group.addTask {
                if (!self.data.chunithm.musics.isEmpty) {
                    if (!self.chunithm.best.isEmpty) {
                        self.chunithm.best = CFQChunithm.assignAssociated(songs: self.data.chunithm.musics, bests: self.chunithm.best)
                    }
                    if (!self.chunithm.recent.isEmpty) {
                        self.chunithm.recent = CFQChunithm.assignAssociated(songs: self.data.chunithm.musics, recents: self.chunithm.recent)
                    }
                    if (!self.chunithm.rating.isEmpty) {
                        self.chunithm.rating = CFQChunithm.assignAssociated(bests: self.chunithm.best, ratings: self.chunithm.rating)
                    }
                }
            }
        }
        print("[CFQNUser] Assigned Associated Song Data.")
        
        let failed = filterAssociated()
        if (!failed.isEmpty) {
            failed.forEach { deleted in
                print("[CFQNUser] Found deleted music: \(deleted)")
            }
            // throw CFQNUserError.AssociationError(in: failed)
        }
        print("[CFQNUser] Association Assertion Passed.")
        
        if !skipCustomLoading {
            publishLoadStatus("加载用户数据...")
            self.maimai.custom = Maimai.Custom(orig: self.maimai.best, recent: self.maimai.recent, list: self.data.maimai.songlist, delta: self.maimai.delta)
            self.chunithm.custom = Chunithm.Custom(orig: self.chunithm.rating, recent: self.chunithm.recent, best: self.chunithm.best, list: self.data.chunithm.musics, delta: self.chunithm.delta)
            self.maimai.info.nickname = self.maimai.info.nickname.transformingHalfwidthFullwidth()
            self.chunithm.info.nickname = self.chunithm.info.nickname.transformingHalfwidthFullwidth()
            print("[CFQNUser] Calculated Custom Values.")
        }
        
        publishLoadStatus("同步用户设置...")
        await self.remoteOptions.sync(authToken: self.jwtToken)
        
        publishLoadStatus("同步本地存储...")
        sharedContainer.set(self.jwtToken, forKey: "JWT")
        sharedContainer.set(username, forKey: "currentUser")
        print("[CFQNUser] Set jwt token and username to \(username).")
    }
    
    // MARK: Make Widget
    func makeWidgetData() async throws -> WidgetData {
        var maiCover = Data()
        var chuCover = Data()

        if let maiFirst = self.maimai.recent.first {
            do {
                let (data, _) = try await URLSession.shared.data(from: MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: getCoverNumber(id: maiFirst.associatedSong!.musicId)))
                maiCover = data
            } catch {
                maiCover = Data()
            }
        }
        if let chuFirst = self.chunithm.recent.first {
            do {
                let (data, _) = try await URLSession.shared.data(from: ChunithmDataGrabber.getSongCoverUrl(source: 0, musicId: String(chuFirst.associatedSong!.musicID)))
                chuCover = data
            } catch {
                chuCover = Data()
            }
        }
        
        print("[CFQNUser] Fetched recent images: \(maiCover.count), \(chuCover.count)")

        var data = WidgetData(
            username: self.username,
            isPremium: self.isPremium,
            maimaiInfo: self.maimai.isNotEmpty ? self.maimai.info : nil,
            chunithmInfo: self.chunithm.isNotEmpty ? self.chunithm.info : nil,
            maiRecentOne: self.maimai.recent.first,
            chuRecentOne: self.chunithm.recent.first,
            chuCover: chuCover,
            maiCover: maiCover,
            custom: nil)
        
        if isPremium {
            do {
                let custom = try JSONDecoder().decode(WidgetData.Customization.self, from: widgetCustom)
                data.custom = custom
                
                if let chuCharUrlString = custom.chuCharUrl, let chuCharUrl = URL(string: chuCharUrlString) {
                    let (chuCharData, _) = try await URLSession.shared.data(from: chuCharUrl)
                    data.chuChar = chuCharData
                }
                
                if let chuBgUrlString = custom.chuBgUrl, let chuBgUrl = URL(string: chuBgUrlString) {
                    let (chuBgData, _) = try await URLSession.shared.data(from: chuBgUrl)
                    data.chuBg = chuBgData
                }
                
                if let maiCharUrlString = custom.maiCharUrl, let maiCharUrl = URL(string: maiCharUrlString) {
                    let (maiCharData, _) = try await URLSession.shared.data(from: maiCharUrl)
                    data.maiChar = maiCharData
                }
                
                if let maiBgUrlString = custom.maiBgUrl, let maiBgUrl = URL(string: maiBgUrlString) {
                    let (maiBgData, _) = try await URLSession.shared.data(from: maiBgUrl)
                    data.maiBg = maiBgData
                }
            } catch {
                data.custom = nil
            }
        }
        
        return data
    }
    
    func publishLoadStatus(_ string: String) {
        DispatchQueue.main.async {
            self.loadPrompt = string
        }
    }
    
    func testFishToken() async -> Bool {
        guard !remoteOptions.fishToken.isEmpty else {
            return true
        }
        
        do {
            let url = URL(string: "https://www.diving-fish.com/api/maimaidxprober/player/profile")!
            var request = URLRequest(url: url)
            
            request.httpMethod = "GET"
            request.setValue("jwt_token=\(remoteOptions.fishToken)", forHTTPHeaderField: "Cookie")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            return response.statusCode() == 200
        } catch {
            return false
        }
    }
    
    func makeB50() -> MaimaiB50Info {
        return MaimaiB50Info(username: self.username, info: MaimaiB50Detail(
            rating: self.maimai.info.rating,
            newRating: self.maimai.custom.currentRating,
            pastRating: self.maimai.custom.pastRating,
            nickname: self.maimai.info.nickname,
            b35: self.maimai.custom.pastSlice.enumerated().map { index, entry in
                MaimaiB50Entry(index: index, title: entry.title, level: entry.level, achievements: entry.score, constant: entry.associatedSong?.constant[entry.levelIndex] ?? 0.0, rating: entry.rating, fc: entry.fc, diffIndex: entry.levelIndex, musicId: entry.associatedSong?.musicId ?? "")
            },
            b15: self.maimai.custom.currentSlice.enumerated().map { index, entry in
                MaimaiB50Entry(index: index, title: entry.title, level: entry.level, achievements: entry.score, constant: entry.associatedSong?.constant[entry.levelIndex] ?? 0.0, rating: entry.rating, fc: entry.fc, diffIndex: entry.levelIndex, musicId: entry.associatedSong?.musicId ?? "")
            }
        ))
    }
}

enum CFQNUserError: Error {
    case SavingError(cause: String, from: String)
    case LoadingError(cause: String, from: String)
    case AssociationError(in: [String])
}

extension CFQNUserError: CustomStringConvertible {
    var description: String {
        switch self {
        case .SavingError(cause: let cause, from: let from):
            return from + cause
        case .LoadingError(cause: let cause, from: let from):
            return from + cause
        case .AssociationError:
            return "关联歌曲出现错误"
        }
    }
}

extension Int {
    mutating func toggle() {
        if (self == 1) {
            self = 0
        } else if (self == 0) {
            self = 1
        }
    }
}

let recommendWeights = [
    "MAX": 20, // AP+ / AJC
    "AP": 10,
    "AJ": 10,
    "FC": 9, // FC/FS/FC+/FS+/FDX
    "HS": 7, // Highscore
    "NR": 8, // New Record
    "RO": 5  // Recent
]

let recommendPrompts = [
    "MAX": "理论值",
    "AP": "AP",
    "AJ": "AJ",
    "FC": "FC",
    "HS": "高分",
    "NR": "新纪录",
    "RO": "最近一首"
]

extension String {
    func transformingHalfwidthFullwidth() -> String {
        let str = NSMutableString(string: self)
        CFStringTransform(str, nil, kCFStringTransformFullwidthHalfwidth, false)
        return str as String
    }
}
