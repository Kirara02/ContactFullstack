//
//  ContactRepository.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import Foundation

class ContactRepositoryImpl: ContactRepositoryProtocol {
    private let httpClient = HTTPClient()
    private let baseURL = "http://localhost:3000/contacts"
    
    // Fetch all contacts
    func fetchContacts() async throws -> [Contact] {
        guard let url = URL(string: baseURL) else {
            throw HTTPError.invalidURL
        }
        
        do {
            let contacts: [Contact] = try await httpClient.request(url: url, method: .get)
            return contacts
        } catch {
            throw error // Penanganan error yang lebih baik bisa dilakukan di sini
        }
    }
    
    // Add a new contact
    func addContact(_ contact: Contact) async throws -> Contact {
        guard let url = URL(string: baseURL) else {
            throw HTTPError.invalidURL
        }
        
        do {
            let newContact: Contact = try await httpClient.request(url: url, method: .post, body: contact)
            return newContact
        } catch {
            throw error // Penanganan error yang lebih baik bisa dilakukan di sini
        }
    }
    
    // Update an existing contact
    func updateContact(_ contact: Contact) async throws -> Contact {
        guard let id = contact.id, let url = URL(string: "\(baseURL)/\(id)") else {
            throw HTTPError.invalidURL
        }
        
        do {
            let updatedContact: Contact = try await httpClient.request(url: url, method: .put, body: contact)
            return updatedContact
        } catch {
            throw error // Penanganan error yang lebih baik bisa dilakukan di sini
        }
    }
    
    // Delete a contact
    func deleteContact(_ contact: Contact) async throws {
        guard let id = contact.id, let url = URL(string: "\(baseURL)/\(id)") else {
            throw HTTPError.invalidURL
        }
        
        do {
            try await httpClient.requestWithoutBody(url: url, method: .delete)
        } catch {
            throw error // Penanganan error yang lebih baik bisa dilakukan di sini
        }
    }
}

