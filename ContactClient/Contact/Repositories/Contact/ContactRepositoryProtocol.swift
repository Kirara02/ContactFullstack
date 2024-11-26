//
//  ContactRepositoryProtocol.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import Foundation

protocol ContactRepositoryProtocol {
    func fetchContacts() async throws -> [Contact]
    func addContact(_ contact: Contact) async throws -> Contact
    func updateContact(_ contact: Contact) async throws -> Contact
    func deleteContact(_ contact: Contact) async throws
}
