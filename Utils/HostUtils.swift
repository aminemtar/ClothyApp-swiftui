//
//  HostUtils.swift
//  ClothyApp
//
//  Centralized API host configuration.
//

import Foundation

/// Development API endpoint.
///
/// IMPORTANT: this private-network address is only reachable when the backend
/// is running on the same network. Replace it with your HTTPS production API
/// URL before distributing the app. Plain HTTP may also require an ATS
/// exception in the app's Info.plist.
enum HostUtils {
    static let baseURL = URL(string: "http://192.168.1.7:9090/")!

    static func endpoint(_ path: String) -> URL {
        baseURL.appendingPathComponent(path)
    }
}
