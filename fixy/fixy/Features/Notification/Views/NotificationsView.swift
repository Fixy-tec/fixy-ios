//
//  NotificationsView.swift
//  fixy
//
//  Created by yordan on 27/06/26.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView("Cargando notificaciones...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No tienes notificaciones")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.notifications) { notification in
                                notificationRow(notification)
                                Divider()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notificaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await viewModel.markAllAsRead() }
                    }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
            .task {
                await viewModel.fetchNotifications()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private func notificationRow(_ notification: NotificationModel) -> some View {
        let isRead = notification.is_read ?? false
        let icon = viewModel.iconData(for: notification.title)
        
        Group {
            if let requestId = notification.related_request_id {
                NavigationLink(destination: RequestDetailView(requestId: requestId)) {
                    rowContent(notification: notification, isRead: isRead, icon: icon)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    if !isRead { Task { await viewModel.markAsRead(notificationId: notification.id) } }
                })
            } else {
                rowContent(notification: notification, isRead: isRead, icon: icon)
                    .onTapGesture {
                        if !isRead { Task { await viewModel.markAsRead(notificationId: notification.id) } }
                    }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func rowContent(notification: NotificationModel, isRead: Bool, icon: (name: String, color: String)) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(colorFromName(icon.color).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon.name)
                    .foregroundColor(colorFromName(icon.color))
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(isRead ? .regular : .bold)
                    .foregroundColor(.primary)
                
                if let message = notification.message, !message.isEmpty {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(viewModel.timeAgoDisplay(dateString: notification.created_at))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isRead ? Color(UIColor.systemBackground) : Color.gray.opacity(0.08))
    }
    
    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "green": return .green
        case "yellow": return .yellow
        case "teal": return .teal
        default: return .blue
        }
    }
}
