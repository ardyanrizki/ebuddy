//
//  UsersView.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import SwiftUI

struct UsersView: View {
    @State var viewModel = UsersViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                Text("Loading...")
            } else {
                List(viewModel.users) { user in
                    UserRowView(user)
                }
                .refreshable {
                    viewModel.fetchUsers()
                }
            }
        }
        .navigationTitle("Users")
    }
}

struct UserRowView: View {
    var user: UserJSON
    
    init(_ user: UserJSON) {
        self.user = user
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Circular avatar placeholder
            Circle()
                .fill((user.gender == .female ? Color.pink : Color.blue).opacity(0.3))
                .frame(width: 48, height: 48)
                .overlay(
                    Text((user.email ?? "").prefix(1).uppercased())
                        .font(.title)
                        .foregroundColor(.white)
                )
            
            // User details
            VStack(alignment: .leading, spacing: 8) {
                Text(user.email ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                    Text((user.gender?.stringValue ?? "").capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.secondary)
                    Text(user.phoneNumber ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
    }
}

#Preview {
    UsersView()
}
