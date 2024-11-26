//
//  ContactDetailView.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import SwiftUI

struct ContactDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ContactViewModel
    var contact: Contact
    @State private var name: String
    @State private var phone: String
    @State private var email: String
    @State private var address: String
    @State private var showToast = false

    init(contact: Contact, viewModel: ContactViewModel) {
        self.contact = contact
        self.viewModel = viewModel
        _name = State(initialValue: contact.name)
        _phone = State(initialValue: contact.phone)
        _email = State(initialValue: contact.email)
        _address = State(initialValue: contact.address ?? "")
    }

    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $name)
                TextField("Phone", text: $phone)
                TextField("Email", text: $email)
                TextField("Address", text: $address)
            }

            // Toast message
            if showToast {
                Text(viewModel.errorMessage ?? "Something went wrong")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                    .transition(.slide)
                    .animation(.easeInOut, value:"")
                    .padding(.bottom, 20)
                    .onAppear {
                        // Dismiss the toast after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showToast = false
                        }
                    }
            }
        }
        .navigationTitle("Edit Contact")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    var updatedContact = contact
                    updatedContact.name = name
                    updatedContact.phone = phone
                    updatedContact.email = email
                    updatedContact.address = address
                    Task {
                        await viewModel.updateContact(updatedContact)
                        if let errorMessage = viewModel.errorMessage {
                            showToast = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
