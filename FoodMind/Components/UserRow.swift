//
//  UserRow.swift
//  FoodMind
//
//  Created by Ahmad on 16/03/2026.
//

import SwiftUI

struct UserRow: View {
 
    @Binding var user: FMSearchUser
 
    var body: some View {
        HStack(spacing: 12) {
 
            // Avatar
            ZStack {
                Circle()
                    .fill(FMColors.surface2)
                    .frame(width: 46, height: 46)
                Text(user.avatar)
                    .font(.system(size: 26))
            }
 
            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(FMColors.cream)
 
                    if user.isFollowing {
                        Text("Following")
                            .font(.system(size: 9))
                            .foregroundColor(FMColors.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(FMColors.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
 
                Text("@\(user.username) · \(user.location)")
                    .font(.system(size: 12))
                    .foregroundColor(FMColors.cream25)
 
                // Top dish + avg calories
                HStack(spacing: 6) {
                    Text(user.topDishEmoji + " " + user.topDish)
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream.opacity(0.45))
 
                    Text("·")
                        .foregroundColor(FMColors.cream25)
 
                    Text("avg \(user.avgCalories) kcal")
                        .font(.system(size: 11))
                        .foregroundColor(FMColors.cream.opacity(0.45))
                }
            }
 
            Spacer()
 
            // Follow / Following button
            Button {
                withAnimation(.spring(response: 0.3)) {
                    user.isFollowing.toggle()
                }
            } label: {
                Text(user.isFollowing ? "Following" : "Follow")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(
                        user.isFollowing
                            ? FMColors.cream.opacity(0.5)
                            : FMColors.background
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        user.isFollowing
                            ? FMColors.surface2
                            : FMColors.green
                    )
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                user.isFollowing
                                    ? FMColors.border
                                    : .clear,
                                lineWidth: 1
                            )
                    )
            }
        }
        .padding(12)
        .background(FMColors.surface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(FMColors.border2, lineWidth: 1)
        )
    }
}
