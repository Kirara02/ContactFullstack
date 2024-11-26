//
//  ContactListView.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import SwiftUI

struct ContactListView: View {
    @StateObject private var viewModel = ContactViewModel()
    @State private var showAddContent = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.contacts) { contact in
                    NavigationLink (
                        destination: ContactDetailView(
                            contact: contact,
                            viewModel: viewModel)
                    ) {
                        Text(contact.name)
                    }
                }
                .onDelete { indexSet in
                    guard let index = indexSet.first else { return }
                    let contactToDelete = viewModel.contacts[index]
                    Task {
                        await viewModel.deleteContact(contactToDelete)
                    }
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddContent.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddContent) {
                AddContactView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchContacts()
            }
        }
    }
}

#Preview {
    ContactListView()
}
