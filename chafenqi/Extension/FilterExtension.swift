//
//  FilterExtension.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/28.
//

import Foundation

extension Array<ChunithmMusicData> {
    func filterTitle(keyword: String) -> Array<ChunithmMusicData> {
        self.filter {
            $0.title.lowercased().contains(keyword.lowercased())
        }
    }
    
    func filterArtist(keyword: String) -> Array<ChunithmMusicData> {
        self.filter {
            $0.artist.lowercased().contains(keyword.lowercased())
        }
    }
    
    func filterTitleAndArtist(keyword: String) -> Array<ChunithmMusicData> {
        self.filter {
            $0.title.localizedCaseInsensitiveContains(keyword) ||
            $0.artist.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    func filterConstant(lower: Double, upper: Double) -> Array<ChunithmMusicData> {
        self.filter {
            for constant in $0.charts.constants {
                if(lower...upper ~= constant) {
                    return true
                }
            }
            
            return false
        }
    }
    
    func filterLevel(lower: String, upper: String) -> Array<ChunithmMusicData> {
        let lowerDigit = levelToDigit(level: lower)
        let upperDigit = levelToDigit(level: upper)
        return self.filter {
            for level in $0.charts.levels {
                if(lowerDigit...upperDigit ~= levelToDigit(level: level)) {
                    return true
                }
            }
            return false
        }
    }
    
    func filterGenre(keywords: Array<String>) -> Array<ChunithmMusicData> {
        self.filter {
            keywords.contains($0.genre)
        }
    }
    
    func filterVersion(keywords: Array<String>) -> Array<ChunithmMusicData> {
        self.filter {
            keywords.contains($0.from)
        }
    }
    
    func filterPlayed(idList: Array<Int>) -> Array<ChunithmMusicData> {
        self.filter {
            idList.contains($0.musicID)
        }
    }
    
}

extension Array<MaimaiSongData> {
    func filterTitleAndArtist(keyword: String) -> Self {
        self.filter {
            $0.title.localizedCaseInsensitiveContains(keyword) ||
            $0.basicInfo.artist.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    func filterConstant(lower: Double, upper: Double) -> Self {
        self.filter {
            for constant in $0.constant {
                if (lower...upper ~= constant) {
                    return true
                }
            }
            
            return false
        }
    }
    
    func filterLevel(lower: String, upper: String) -> Self {
        let lowerDigit = levelToDigit(level: lower)
        let upperDigit = levelToDigit(level: upper)
        return self.filter {
            for level in $0.level {
                if(lowerDigit...upperDigit ~= levelToDigit(level: level)) {
                    return true
                }
            }
            
            return false
        }
    }
}

func levelToDigit(level: String) -> Double {
    if (level.contains("+")) {
        var formattedLevelString = level
        formattedLevelString = formattedLevelString.replacingOccurrences(of: "+", with: ".5")
        return Double(formattedLevelString) ?? 0.0
    } else {
        return Double(level) ?? 0.0
    }
}

func anyCommonElements <T, U> (lhs: T, rhs: U) -> Bool where T: Sequence, U: Sequence, T.Iterator.Element: Equatable, T.Iterator.Element == U.Iterator.Element {
    for lhsItem in lhs {
        for rhsItem in rhs {
            if lhsItem == rhsItem {
                return true
            }
        }
    }
    return false
}
