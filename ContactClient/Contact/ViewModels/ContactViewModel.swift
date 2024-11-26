//
//  ContactViewModel.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import Foundation

@MainActor
class ContactViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var errorMessage: String? = nil
    
    private let repository: ContactRepositoryProtocol
        
    // Inisialisasi dengan dependency injection untuk repository
    init(repository: ContactRepositoryProtocol = ContactRepositoryImpl()) {
        self.repository = repository
    }
        
    // Fetch all contacts
    func fetchContacts() async {
        do {
            self.contacts = try await repository.fetchContacts()
            errorMessage = nil
        } catch {
            print("Failed to fetch contacts:", error.localizedDescription)
        }
    }
    
    // Add a new contact
    func addContact(_ contact: Contact) async {
        do {
            let newContact = try await repository.addContact(contact)
            errorMessage = nil
            contacts.append(newContact)
        } catch let error as HTTPError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "An unknown error occurred"
        }
    }
    
    // Update an existing contact
    func updateContact(_ contact: Contact) async {
        do {
            let updatedContact = try await repository.updateContact(contact)
            errorMessage = nil
            if let index = contacts.firstIndex(where: { $0.id == updatedContact.id }) {
                contacts[index] = updatedContact
            }
        } catch let error as HTTPError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "An unknown error occurred"
        }
    }
    
    // Delete a contact
    func deleteContact(_ contact: Contact) async {
        do {
            try await repository.deleteContact(contact)
            errorMessage = nil
            contacts.removeAll { $0.id == contact.id }
        } catch {
            print("Failed to delete contact:", error.localizedDescription)
        }
    }
}
