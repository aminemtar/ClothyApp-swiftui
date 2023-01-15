//
//  User.swift
//  ClothyApp
//
//  Created by haithem ghattas on 17/12/2022.
//

import Foundation

struct User: Codable {
    let firstname, lastname, pseudo: String
    let birthdate : String
    let imageF, email: String
    let phone: Int
    let password: String
    let isVerified: Bool
    let preference: String
    let gender, id, createdAt, updatedAt: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case firstname, lastname, birthdate, pseudo, imageF, email, phone, password, isVerified, preference, gender
        case id = "_id"
        case createdAt, updatedAt
        case v = "__v"
    }
}
