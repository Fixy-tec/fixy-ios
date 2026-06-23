//
//  NotificationsView.swift
//  fixy
//
//  Created by yordan on 23/06/26.
//

import SwiftUI
import Supabase

@Observable
@MainActor
final class NotificationsViewModel {
    var notifications: [NotificationDTO] = []
    var isLoading = true
    
    func loadAllNotifications() async {
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        do {
            let fetched: [NotificationDTO] = try await SupabaseManager.shared.client
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.notifications = fetched
        } catch {
            print("❌ Error cargando todas las notificaciones: \(error)")
        }
        self.isLoading = false
    }
    
    func markAsRead(notificationId: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: notificationId)
                .execute()
            
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                notifications[index].is_read = true
            }
        } catch {
            print("Error marcando como leída: \(error)")
        }
    }
}

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando notificaciones...")
            } else if viewModel.notifications.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No tienes notificaciones").font(.headline)
                }
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        NavigationLink(destination: Group {
                            if let reqId = notification.related_request_id {
                                RequestDetailView(requestId: reqId)
                            } else {
                                Text("Detalle no disponible")
                            }
                        }) {
                            notificationRow(notification: notification)
                        }
                        .onAppear {
                            // Marcar como leída al verla en pantalla
                            if !notification.is_read {
                                Task { await viewModel.markAsRead(notificationId: notification.id) }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadAllNotifications() }
    }
    
    private func notificationRow(notification: NotificationDTO) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(notification.is_read ? Color.clear : Color.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(notification.is_read ? .regular : .bold)
                if let msg = notification.message {
                    Text(msg).font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
