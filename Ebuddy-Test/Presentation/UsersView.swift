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
                    NavigationLink {
                        UserDetailsView(userId: user.uid ?? "")
                    } label: {
                        UserRowView(user)
                            .environment(viewModel)
                    }

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
    
    @Environment(UsersViewModel.self) private var viewModel
    
    @State private var isShowingConfirmationDialog = false
    @State private var isUploading = false
    @State private var currentUser: UIImage?
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(_ user: UserJSON) {
        self.user = user
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Circular avatar placeholder
            if let avatar = user.avatar, let avatarURL = URL(string: avatar) {
                AsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(.white)
                        .frame(width: 48, height: 48)
                        .overlay(
                            ProgressView()
                        )
                }
                
            } else if isUploading {
                Circle()
                    .fill(.white)
                    .frame(width: 48, height: 48)
                    .overlay(
                        ProgressView()
                    )
                
            } else {
                Circle()
                    .fill((user.gender == .female ? Color.pink : Color.blue).opacity(0.3))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text((user.email ?? "").prefix(1).uppercased())
                            .font(.title)
                            .foregroundColor(.white)
                    )
                    .onTapGesture {
                        isShowingConfirmationDialog = true
                    }
            }
            
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
        .confirmationDialog("Upload Profile Image", isPresented: $isShowingConfirmationDialog, titleVisibility: .visible) {
            Button("Take Photo") {
                sourceType = .camera
                isShowingImagePicker = true
            }
            Button("Choose from Library") {
                sourceType = .photoLibrary
                isShowingImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $selectedImage, isPresented: $isShowingImagePicker)
        }
        .onChange(of: isShowingImagePicker) { oldValue, newValue in
            Task {
                if oldValue, !newValue {
                    guard let selectedImage else {
                        return
                    }
                    for await isLoading in viewModel.uploadAvatar(image: selectedImage, for: user) {
                        self.isUploading = isLoading
                    }
                    self.selectedImage = nil
                }
            }
        }
    }
}

#Preview {
    UsersView()
}
