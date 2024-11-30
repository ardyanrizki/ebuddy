//
//  FigmaDesignView.swift
//  Ebuddy-Test
//
//  Created by Muhammad Rizki Ardyan on 30/11/24.
//

import SwiftUI

struct FigmaDesignView: View {
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        HStack {
                            HStack(spacing: 8) {
                                Image(.logo)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 24)
                                
                                Circle()
                                    .fill(.green)
                                    .frame(width: 8, height: 8)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Image(.verified)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 20)
                                
                                Image(.instagramIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 20)
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        ZStack(alignment: .bottom) {
                            Image(.user1)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 158, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            
                            HStack {
                                HStack(spacing: 0) {
                                    Image(.category1)
                                    Image(.category2)
                                        .offset(x: -8)
                                }
                                
                                Spacer()
                                
                                Image(.voice)
                            }
                            .padding(.horizontal, 8)
                            .offset(y: 16)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(.star)
                            Text("4.9")
                            Text("(61)")
                                .foregroundStyle(.gray)
                        }
                        
                        HStack {
                            Image(.mana)
                            Text("110") +
                            Text(".00/1Hr")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .frame(width: 166, height: 312)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    FigmaDesignView()
}
