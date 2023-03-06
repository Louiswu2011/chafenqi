//
//  FilterExtension.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/28.
//

import Foundation

extension Array<ChunithmSongData> {
    func filterTitle(keyword: String) -> Array<ChunithmSongData> {
        self.filter {
            $0.basicInfo.title.lowercased().contains(keyword.lowercased())
        }
    }
    
    func filterArtist(keyword: String) -> Array<ChunithmSongData> {
        self.filter {
            $0.basicInfo.artist.lowercased().contains(keyword.lowercased())
        }
    }
    
    func filterTitleAndArtist(keyword: String) -> Array<ChunithmSongData> {
        self.filter {
            $0.basicInfo.title.lowercased().contains(keyword.lowercased()) || $0.basicInfo.artist.lowercased().contains(keyword.lowercased())
        }
    }
    
    func filterCombo(levelIndex: Int, lower: Int, upper: Int) -> Array<ChunithmSongData> {
        self.filter {
            lower...upper ~= $0.charts[levelIndex].combo
        }
    }
    
    func filterConstant(lower: Double, upper: Double) -> Array<ChunithmSongData> {
        self.filter {
            for constant in $0.constant {
                if(lower...upper ~= constant) {
                    return true
                }
            }
            
            return false
        }
    }
    
    func filterLevel(lower: String, upper: String) -> Array<ChunithmSongData> {
        let lowerDigit = levelToDigit(level: lower)
        let upperDigit = levelToDigit(level: upper)
        return self.filter {
            for level in $0.level {
                if (lowerDigit...upperDigit ~= levelToDigit(level: level)) {
                    return true
                }
            }
            return false
        }
    }
    
    func filterGenre(keywords: Array<String>) -> Array<ChunithmSongData> {
        self.filter {
            keywords.contains($0.basicInfo.genre)
        }
    }
    
    func filterVersion(keywords: Array<String>) -> Array<ChunithmSongData> {
        self.filter {
            keywords.contains($0.basicInfo.from)
        }
    }
    
    func filterPlayed(idList: Array<Int>) -> Array<ChunithmSongData> {
        self.filter {
            idList.contains($0.musicId)
        }
    }
    
    private func levelToDigit(level: String) -> Double {
        if (level.contains("+")) {
            var formattedLevelString = level
            formattedLevelString = formattedLevelString.replacingOccurrences(of: "+", with: ".5")
            return Double(formattedLevelString) ?? 0.0
        } else {
            return Double(level) ?? 0.0
        }
    }
}
