//
//  MyRequestsViewModel.swift
//  fixy
//
//  Created by yordan on 26/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class MyRequestsViewModel {
    
    // Listas para las 4 pestañas
    var myApplications: [MyApplicationDTO] = []
    var myCreatedRequests: [MyRequestDTO] = []
    var inProcessRequests: [MyRequestDTO] = []
    var completedRequests: [MyRequestDTO] = []
    
    var isLoading: Bool = false
    
    // MARK: - Consultas (FETCH)
    
    func fetchAllData() async {
        isLoading = true
        await fetchMyApplications()
        await fetchMyCreatedRequests()
        await fetchInProcessRequests()
        await fetchCompletedRequests()
        isLoading = false
    }
    
    // 1. Postulaciones (Donde yo soy el postulante)
    private func fetchMyApplications() async {
        guard let userId = try? await SupabaseManager.shared.client.auth.session.user.id else { return }
        do {
            let fetched: [MyApplicationDTO] = try await SupabaseManager.shared.client
                .from("applications")
                .select("*, requests(*, profiles(full_name, medal))")
                .eq("applicant_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            self.myApplications = fetched
        } catch { print("Error cargando postulaciones: \(error)") }
    }
    
    // 2. Creadas (Mis solicitudes abiertas/canceladas)
    private func fetchMyCreatedRequests() async {
        guard let userId = try? await SupabaseManager.shared.client.auth.session.user.id else { return }
        do {
            let fetched: [MyRequestDTO] = try await SupabaseManager.shared.client
                .from("requests")
                .select("*, profiles(full_name, medal)")
                .eq("creator_id", value: userId)
                .in("status", values: ["abierta", "cancelada"]) // Mostramos abiertas y canceladas aquí
                .order("created_at", ascending: false)
                .execute()
                .value
            self.myCreatedRequests = fetched
        } catch { print("Error cargando creadas: \(error)") }
    }
    
    // 3. En Proceso
    private func fetchInProcessRequests() async {
        guard let userId = try? await SupabaseManager.shared.client.auth.session.user.id else { return }
        do {
            let fetched: [MyRequestDTO] = try await SupabaseManager.shared.client
                .from("requests")
                .select("*, profiles(full_name, medal)")
                .eq("creator_id", value: userId)
                .eq("status", value: "en_proceso")
                .order("created_at", ascending: false)
                .execute()
                .value
            self.inProcessRequests = fetched
        } catch { print("Error cargando en proceso: \(error)") }
    }
    
    // 4. Completadas (y pendientes de calificar)
    private func fetchCompletedRequests() async {
        guard let userId = try? await SupabaseManager.shared.client.auth.session.user.id else { return }
        do {
            let fetched: [MyRequestDTO] = try await SupabaseManager.shared.client
                .from("requests")
                .select("*, profiles(full_name, medal)")
                .eq("creator_id", value: userId)
                .in("status", values: ["completada", "calificada"])
                .order("created_at", ascending: false)
                .execute()
                .value
            self.completedRequests = fetched
        } catch { print("Error cargando completadas: \(error)") }
    }
    
    // MARK: - Acciones (POST, DELETE, UPDATE)
    
    func withdrawApplication(applicationId: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("applications")
                .delete()
                .eq("id", value: applicationId)
                .execute()
            await fetchMyApplications() // Recargar lista
        } catch { print("Error retirando postulación: \(error)") }
    }
    
    func deleteRequest(requestId: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("requests")
                .delete()
                .eq("id", value: requestId)
                .execute()
            await fetchMyCreatedRequests()
        } catch { print("Error eliminando solicitud: \(error)") }
    }
    
    func cancelRequest(requestId: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("requests")
                .update(["status": "cancelada"])
                .eq("id", value: requestId)
                .execute()
            await fetchMyCreatedRequests()
        } catch { print("Error cancelando solicitud: \(error)") }
    }
    
    func markAsCompleted(requestId: UUID) async {
        do {
            try await SupabaseManager.shared.client
                .from("requests")
                .update(["status": "completada"])
                .eq("id", value: requestId)
                .execute()
            await fetchAllData() // Recargar todo para moverla de pestaña
        } catch { print("Error marcando como completada: \(error)") }
    }
    
    // Llamada a la función RPC de Supabase que creamos en SQL
    func submitReview(requestId: UUID, revieweeId: UUID, rating: Double, comment: String, pointsReward: Int) async {
        guard let session = try? await SupabaseManager.shared.client.auth.session else { return }
        let userId = session.user.id
        
        // Obtenemos los datos del reviewer (el usuario actual) para guardarlos en la reseña
        guard let myProfile: ProfileDTO = try? await SupabaseManager.shared.client
            .from("profiles").select().eq("id", value: userId).single().execute().value else { return }
        
        let reviewerName = myProfile.full_name ?? "Usuario"
        let initials = String(reviewerName.prefix(2)).uppercased()
        
        let params: [String: AnyJSON] = [
            "p_request_id": .string(requestId.uuidString),
            "p_reviewee_id": .string(revieweeId.uuidString),
            "p_reviewer_name": .string(reviewerName),
            "p_reviewer_initials": .string(initials),
            "p_rating": .double(rating), 
            "p_comment": .string(comment),
            "p_points_reward": .integer(pointsReward)
        ]
        
        do {
            try await SupabaseManager.shared.client
                .rpc("procesar_calificacion_y_recompensa", params: params)
                .execute()
            await fetchAllData()
        } catch {
            print("Error enviando calificación: \(error)")
        }
    }
}
