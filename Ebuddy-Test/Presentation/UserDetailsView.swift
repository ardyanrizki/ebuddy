//
//  UserDetailsView.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import SwiftUI

struct UserDetailsView: View {
    @State var viewModel: UserDetailsViewModel
    
    @State private var isShowingConfirmationDialog = false
    @State private var isUploading = false
    @State private var currentUser: UIImage?
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(userId: String) {
        self.viewModel = UserDetailsViewModel(userId: userId)
        
    }

    var body: some View {
        if let user = viewModel.user {
            VStack(spacing: 32) {
                // Circular avatar placeholder
                if let avatar = user.avatar, let avatarURL = URL(string: avatar) {
                    AsyncImage(url: avatarURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(.white)
                            .frame(width: 96, height: 96)
                            .overlay(
                                ProgressView()
                            )
                    }
                    
                } else if isUploading {
                    Circle()
                        .fill(.white)
                        .frame(width: 96, height: 96)
                        .overlay(
                            ProgressView()
                        )
                    
                } else {
                    Circle()
                        .fill((user.gender == .female ? Color.pink : Color.blue).opacity(0.3))
                        .frame(width: 96, height: 96)
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
                VStack(alignment: .center, spacing: 8) {
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
            .padding()
            .frame(maxHeight: .infinity, alignment: .center)
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
        } else {
            ProgressView()
        }
        
    }
}
