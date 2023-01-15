//
//  UserViewModal.swift
//  ClothyApp
//
//  Created by haithem ghattas on 17/12/2022.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

final class UsersViewModel : ObservableObject{
    public func isValidPassword(password : String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    func textFieldValidatorEmail(pseudo: String ,lastname: String ,firstname: String , email: String,completed:(Bool,Int) -> Void) {
        
        let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        //let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        if (pseudo.count > 15 || pseudo.count < 3){
            completed (false,3)
        }
        else
        if (firstname.count > 15 || firstname.count < 3){
            completed (false,1)
        } else
        if (lastname.count > 15 || lastname.count < 3){
            completed (false,2)
        } else
        if email.count > 100 {
        
            completed (false,0)
        } else
      
        if (!emailPredicate.evaluate(with: email)){
            completed (false,0)
        }
       else {
            completed (true,9)
        }
    
      
    }

    func connexion(email: String , password: String ,completed: @escaping (Bool) -> Void)  {
        
        AF.request(HostUtils().HOST_URL+"api/login",
                   method: .post,
                   parameters: ["email": email, "password": password], encoding: JSONEncoding.default)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        
        .responseData { [self] response in
            switch response.result {
                
            case .success:
                let jsonData = JSON(response.data!)
                print(jsonData)
                //User().pseudo = jsonData["pseudo"].stringValue
           //     let utilisateur = self.makeItem(jsonItem: jsonData["userr"])
                UserDefaults.standard.setValue(jsonData["_id"].stringValue, forKey: "session")
                //Bool  //setObject
                print( UserDefaults.standard.string(forKey: "session") ?? "didnt store :ccccc ")

                // UserDefaults.standard.setValue(utilisateur._id, forKey: "_id")
                //       UserDefaults.standard.setValue(self.utilisateur.firstname, forKey: "firstname")
                
                //isAuthenticated = true
                
                //  print(utilisateur.firstname ?? "aaz")
                
                
              //  self.isAuthenticated = true
                completed(true)
            case let .failure(error):
                debugPrint(error)
                completed(false)
            }
        }
    }
    func inscription(user: User, completed: @escaping (Bool) -> Void) {
        
        AF.request(HostUtils().HOST_URL+"api/register",
                   method: .post,
                   parameters: [
                    "email": user.email,
                    "password": user.password,
                    "firstname": user.firstname,
                    "lastname":user.lastname,
                    "phone": user.phone,
                    "pseudo": user.pseudo,
                    "gender": user.gender,
                    "preference": user.preference,
                    "birthdate": user.birthdate
                   ] ,encoding: JSONEncoding.default)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseData { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                completed(true)
                
            case let .failure(error):
                print(error)
                completed(false)
            }
        }
    }
    func forgotpassword(email: String, completed: @escaping (Bool) -> Void) {
        AF.request(HostUtils().HOST_URL+"api/forgetpwd",
                   method: .post,
                   parameters: ["email": email], encoding: JSONEncoding.default)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseData { response in
            switch response.result {
            case .success:
                print("mail is sent")
                completed(true)
            case let .failure(error):
                print(error)
                completed(false)
            }
        }
    }
    func forgotpasswordcode(email: String,code: Int , completed: @escaping (Bool) -> Void) {
        AF.request(HostUtils().HOST_URL+"api/changepwcode",
                   method: .post,
                   parameters: ["email": email , "code": code], encoding: JSONEncoding.default)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseData { response in
            switch response.result {
            case .success:
                print("code is true")
                completed(true)
            case let .failure(error):
                print(error)
                completed(false)
            }
        }
    }
    func setnewpw(email: String,newpw: String , completed: @escaping (Bool) -> Void) {
        AF.request(HostUtils().HOST_URL+"api/changepass",
                   method: .put,
                   parameters: ["email": email , "newPassword": newpw ], encoding: JSONEncoding.default)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseData { response in
            switch response.result {
            case .success:
                print("code is true")
                completed(true)
            case let .failure(error):
                print(error)
                completed(false)
            }
        }
    }
    
}
