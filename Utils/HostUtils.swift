//
//  HostUtils.swift
//  ClothyApp
//
//  Centralized API host configuration.
//

import Foundation

/// Development API endpoint.
///
/// This private-network address is only reachable when the backend is running
/// on the same network. Replace it with your HTTPS production API URL before
/// distributing the app. Plain HTTP may also require an ATS exception.
final class HostUtils {
    let HOST_URL = "http://192.168.1.7:9090/"
}
