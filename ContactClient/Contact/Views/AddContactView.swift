//
//  AddContactView.swift
//  Contact
//
//  Created by Uniguard ID on 26/11/24.
//

import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ContactViewModel
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var showToast = false

    var body: some View {
        NavigationView {
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
                        .animation(.easeInOut, value: "")
                        .padding(.bottom, 20)
                        .onAppear {
                            // Dismiss the toast after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                            }
                        }
                }
            }
            .navigationTitle("Add Contact")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newContact = Contact(name: name, email: email, phone: phone, address: address)
                        Task {
                            await viewModel.addContact(newContact)
                            if let errorMessage = viewModel.errorMessage {
                                showToast = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
