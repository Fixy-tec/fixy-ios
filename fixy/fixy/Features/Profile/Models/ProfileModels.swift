//
//  ProfileModels.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation

struct ProfileLink: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let iconName: String
}

struct UserReview: Identifiable {
    let id = UUID()
    let reviewerName: String
    let rating: Double
    let comment: String
    let date: String
    
    var reviewerInitials: String {
        let parts = reviewerName.components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        return String(first + last).uppercased()
    }
}

struct UserProfile {
    var fullName: String
    var career: String
    var cycle: String
    var points: Int
    var rankingPosition: Int
    var rating: Double
    var completedTasks: Int
    var technologies: Set<String>
    var phoneNumber: String
    var links: [ProfileLink]
    var reviews: [UserReview]
    
    var initials: String {
        let parts = fullName.components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        return String(first + last).uppercased()
    }

    // Añadir al final de ProfileModels.swift
    struct ProfileUpdateRequest {
        var fullName: String
        var career: String
        var cycle: String
        var bio: String
        var githubUrl: String
        var linkedinUrl: String
        var portfolioUrl: String
        var selectedAvatar: String
        var customAvatarData: Data?
    }
}
