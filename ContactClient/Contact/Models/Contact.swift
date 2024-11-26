//
//  Contact.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import Foundation

struct Contact: Codable, Hashable, Identifiable {
    var id: Int?
    var name: String
    var email: String
    var phone: String
    var address: String? = nil
}
