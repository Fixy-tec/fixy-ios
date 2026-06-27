//
//  RecentActivityWidget.swift
//  fixy
//
//  Created by yordan on 27/06/26.
//

import SwiftUI

struct RecentActivityWidget: View {
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell")
                Text("ACTIVIDAD RECIENTE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .tracking(1)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if viewModel.notifications.isEmpty {
                    Text("No hay actividad reciente.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.notifications.prefix(4)) { notification in
                        recentActivityRow(notification)
                    }
                }
            }
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
        .task {
            await viewModel.fetchNotifications()
        }
    }
    
    @ViewBuilder
    private func recentActivityRow(_ notification: NotificationModel) -> some View {
        Group {
            if let requestId = notification.related_request_id {
                NavigationLink(destination: RequestDetailView(requestId: requestId)) {
                    activityContent(notification)
                }
            } else {
                activityContent(notification)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func activityContent(_ notification: NotificationModel) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Color.teal)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(viewModel.timeAgoDisplay(dateString: notification.created_at))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
