//
//
//  LyricerView.swift
//  MeowBili
//
//  Created by memz233 on 2024/2/10.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the MeowBili open source project
//
// Copyright (c) 2023 Darock Studio and the MeowBili project authors
// Licensed under GNU General Public License v3
//
// See https://darock.top/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import SwiftUI

struct LyricerView: View {
    var lyrics: [[String: String]]
    @State var nowTime: Double = 10
    @State var nowPlayingIndex = 0
    @State var isShowingBlur = true
    @State var lyricGoTimer: Timer?
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(0..<lyrics.count, id: \.self) { i in
                        HStack {
                            Text(lyrics[i]["content"]!)
                                .font(.system(size: 18, weight: .bold))
                                .opacity(i == nowPlayingIndex ? 1 : 0.6)
                            Spacer()
                        }
                        .tag(i)
                        .listRowBackground(Color.clear)
                    }
                }
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                        lyricGoTimer = timer
                        var loopTimes = 0
                        for lyric in lyrics {
                            let dStartTime = Double(lyric["Start"]!)!
                            let dEndTime = Double(lyric["End"]!)!
                            if nowTime >= dStartTime && nowTime <= dEndTime {
                                withAnimation(.easeOut) {
                                    nowPlayingIndex = loopTimes
                                    proxy.scrollTo(nowPlayingIndex, anchor: .top)
                                }
                                break
                            }
                            loopTimes += 1
                        }
                    }
                    
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                        nowTime += 0.5
                        debugPrint(nowTime)
                    }
                }
                .onDisappear {
                    lyricGoTimer?.invalidate()
                }
            }
            if isShowingBlur {
                VStack {
                    Spacer()
                    Color.clear
                        .frame(height: 60)
                        .background(.ultraThinMaterial)
                        .offset(y: 10)
                        .blur(radius: 4)
                        .ignoresSafeArea()
                }
            }
        }
    }
}

struct LyricerView_Previews: PreviewProvider {
    static var previews: some View {
        LyricerView(lyrics: [["Start": "22.3", "End": "26.025", "content": "chunzhenboidontsmoke is on the track."], ["Start": "30", "End": "32", "content": "chunzhenboidontsmoke is on the track."], ["Start": "32.8", "End": "34", "content": "chunzhenboidontsmoke is on the track."], ["Start": "35.3", "End": "37.1", "content": "chunzhenboidontsmoke is on the track."], ["Start": "38", "End": "39.4", "content": "chunzhenboidontsmoke is on the track."], ["Start": "40.2", "End": "43.8", "content": "chunzhenboidontsmoke is on the track."]])
    }
}
