//
//
//  LiveDetailView.swift
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
import Marquee
import DarockKit
import Alamofire
import SwiftyJSON
import CachedAsyncImage
import SDWebImageSwiftUI

struct LiveDetailView: View {
    var liveDetails: [String: String]
    public static var willPlayStreamUrl = ""
    @AppStorage("DedeUserID") var dedeUserID = ""
    @AppStorage("DedeUserID__ckMd5") var dedeUserID__ckMd5 = ""
    @AppStorage("SESSDATA") var sessdata = ""
    @AppStorage("bili_jct") var biliJct = ""
    @State var watchingCount = 0
    @State var description = ""
    @State var liveStatus = LiveRoomStatus.notStart
    @State var startTime = ""
    @State var streamerId: Int64 = 0
    @State var streamerName = ""
    @State var streamerFaceUrl = ""
    @State var streamerFansCount = 0
    @State var tagName = ""
    @State var backgroundPicOpacity = 0.0
    @State var isDecoded = false
    var body: some View {
        VStack {
            if isDecoded {
                LivePlayerView()
                    .frame(height: 240)
            } else {
                Rectangle()
                    .frame(height: 240)
                    .redacted(reason: .placeholder)
            }
            ScrollView {
                VStack {
                    Spacer()
                    Marquee {
                        HStack {
                            Text(liveDetails["Title"]!)
                                .lineLimit(1)
                                .font(.system(size: 18, weight: .bold))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .marqueeWhenNotFit(true)
                    .marqueeDuration(10)
                    .marqueeIdleAlignment(.center)
                    .frame(height: 20)
                    .padding(.horizontal, 10)
                    Spacer()
                        .frame(height: 20)
                    if streamerId != 0 {
                        NavigationLink(destination: {UserDetailView(uid: String(streamerId))}, label: {
                            HStack {
                                AsyncImage(url: URL(string: streamerFaceUrl + "@40w"))
                                    .cornerRadius(100)
                                    .frame(width: 40, height: 40)
                                VStack {
                                    HStack {
                                        Text(streamerName)
                                            .font(.system(size: 16, weight: .bold))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("Video.fans.\(String(streamerFansCount).shorter())")
                                            .font(.system(size: 11))
                                            .lineLimit(1)
                                            .opacity(0.6)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                        })
                        .buttonBorderShape(.roundedRectangle(radius: 18))
                    }
                    LazyVStack {
                        Spacer()
                            .frame(height: 10)
                        VStack {
                            HStack {
                                Image(systemName: "person.2")
                                Text("Video.details.watching-people.\(watchingCount)")
                                    .offset(x: -1)
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "clock")
                                Text("Live.starting.\(startTime)")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "movieclapper")
                                Text(liveDetails["ID"]!)
                                Spacer()
                            }
                        }
                        .font(.system(size: 11))
                        .opacity(0.6)
                        .padding(.horizontal, 10)
                        Spacer()
                            .frame(height: 5)
                        HStack {
                            VStack {
                                Image(systemName: "info.circle")
                                Spacer()
                            }
                            Text(description)
                            Spacer()
                        }
                        .font(.system(size: 12))
                        .opacity(0.65)
                        .padding(.horizontal, 8)
                        HStack {
                            VStack {
                                Image(systemName: "tag")
                                Spacer()
                            }
                            Text(tagName)
                            Spacer()
                        }
                        .font(.system(size: 12))
                        .opacity(0.65)
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .navigationTitle("Live")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let headers: HTTPHeaders = [
                "cookie": "SESSDATA=\(sessdata)",
                "User-Agent": "Mozilla/5.0 (X11; CrOS x86_64 14541.0.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
            ]
            DarockKit.Network.shared.requestJSON("https://api.live.bilibili.com/room/v1/Room/get_info?room_id=\(liveDetails["ID"]!)") { respJson, isSuccess in
                if isSuccess {
                    watchingCount = respJson["data"]["online"].int ?? 0
                    description = respJson["data"]["description"].string ?? "[加载失败]"
                    liveStatus = LiveRoomStatus(rawValue: respJson["data"]["live_status"].int ?? 0) ?? .notStart
                    startTime = respJson["data"]["live_time"].string ?? "0000-00-00 00:00:00"
                    tagName = respJson["data"]["tags"].string ?? "[加载失败]"
                    if let upUid = respJson["data"]["uid"].int64 {
                        streamerId = upUid
                        biliWbiSign(paramEncoded: "mid=\(upUid)".base64Encoded()) { signed in
                            if let signed {
                                debugPrint(signed)
                                autoRetryRequestApi("https://api.bilibili.com/x/space/wbi/acc/info?\(signed)", headers: headers) { respJson, isSuccess in
                                    if isSuccess {
                                        if !CheckBApiError(from: respJson) { return }
                                        streamerFaceUrl = respJson["data"]["face"].string ?? "E"
                                        streamerName = respJson["data"]["name"].string ?? "[加载失败]"
                                        DarockKit.Network.shared.requestJSON("https://api.bilibili.com/x/relation/stat?vmid=\(upUid)", headers: headers) { respJson, isSuccess in
                                            if isSuccess {
                                                streamerFansCount = respJson["data"]["follower"].int ?? -1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            DarockKit.Network.shared.requestJSON("https://api.live.bilibili.com/room/v1/Room/playUrl?cid=\(liveDetails["ID"]!)&qn=150&platform=h5") { respJson, isSuccess in
                if isSuccess {
                    debugPrint(respJson)
                    LiveDetailView.willPlayStreamUrl = respJson["data"]["durl"][0]["url"].string ?? ""
                    debugPrint(LiveDetailView.willPlayStreamUrl)
                    isDecoded = true
                }
            }
        }
    }
}

enum LiveRoomStatus: Int {
    case notStart = 0
    case streaming = 1
    case playbacking = 2
}

//#Preview {
//    LiveDetailView()
//}
