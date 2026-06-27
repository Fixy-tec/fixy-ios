//
//  RequestDetailViewModel.swift
//  fixy
//
//  Created by yordan on 23/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class RequestDetailViewModel {
    // Datos de la solicitud cargada
    var request: RequestDetailDTO?
    
    // Estados generales
    var isLoading: Bool = true
    var isCreator: Bool = false
    
    // Estados del Postulante
    var hasApplied: Bool = false
    var myApplicationStatus: String = "pendiente"
    var applicationMessage: String = ""
    
    // Estados del Creador (La lista de estudiantes reales que postularon)
    var applicants: [ApplicationDTO] = []
    
    func loadDetails(requestId: UUID) async {
        self.isLoading = true
        guard let currentUserId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        
        do {
            // 1. Cargar la solicitud y los datos de su creador
            let fetchedRequest: RequestDetailDTO = try await SupabaseManager.shared.client
                .from("requests")
                .select("*, profiles(*)")
                .eq("id", value: requestId)
                .single()
                .execute()
                .value
            
            self.request = fetchedRequest
            self.isCreator = (currentUserId == fetchedRequest.creator_id)
            
            // 2. Lógica dependiendo de quién mira la pantalla
            if isCreator {
                // Si soy el creador, cargo a todos los que postularon a mi solicitud
                let fetchedApplicants: [ApplicationDTO] = try await SupabaseManager.shared.client
                    .from("applications")
                    .select("*, profiles(*)")
                    .eq("request_id", value: requestId)
                    .execute()
                    .value
                
                self.applicants = fetchedApplicants
            } else {
                // Si NO soy el creador, reviso si YO ya postulé a esta solicitud
                let myApp: [ApplicationDTO] = try await SupabaseManager.shared.client
                    .from("applications")
                    .select("*, profiles(*)")
                    .eq("request_id", value: requestId)
                    .eq("applicant_id", value: currentUserId)
                    .execute()
                    .value
                
                if let firstApp = myApp.first {
                    self.hasApplied = true
                    self.myApplicationStatus = firstApp.status
                    self.applicationMessage = firstApp.message
                }
            }
        } catch {
            print("Error cargando detalle de solicitud: \(error)")
        }
        
        self.isLoading = false
    }
    
    func apply(message: String) async -> Bool {
        guard let req = request, let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return false }
        
        let application = ApplicationInsert(requestId: req.id, applicantId: userId, message: message)
        
        do {
            try await SupabaseManager.shared.client.from("applications").insert(application).execute()
            self.hasApplied = true
            self.myApplicationStatus = "pendiente"
            self.applicationMessage = message
            return true
        } catch {
            print("Error al postular: \(error)")
            return false
        }
    }
    
    func acceptApplicant(applicationId: UUID) async {
        guard let req = request else { return }
        do {
            // 1. Actualizar el estado de la postulación a 'aprobado'
            try await SupabaseManager.shared.client.from("applications").update(["status": "aprobado"]).eq("id", value: applicationId).execute()
            
            // 2. Actualizar el estado de la solicitud a 'en_proceso'
            try await SupabaseManager.shared.client.from("requests").update(["status": "en_proceso"]).eq("id", value: req.id).execute()
            
            // 3. Refrescar los datos en pantalla
            await loadDetails(requestId: req.id)
            
        } catch {
            print("Error al aceptar postulante: \(error)")
        }
    }
    
    func markAsCompleted() async {
        guard let req = request else { return }
        do {
            try await SupabaseManager.shared.client.from("requests").update(["status": "completada"]).eq("id", value: req.id).execute()
            await loadDetails(requestId: req.id) // Refrescar
        } catch {
            print("Error al completar solicitud: \(error)")
        }
    }
    
    // 🌟 INTEGRACIÓN FASE 4: Función para enviar calificación
    func submitReview(revieweeId: UUID, rating: Double, comment: String) async {
        guard let req = request,
              let userId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        
        // Obtenemos los datos del reviewer (el usuario actual) para la reseña
        guard let myProfile: ProfileDTO = try? await SupabaseManager.shared.client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value else { return }
        
        let reviewerName = myProfile.full_name ?? "Usuario"
        let initials = String(reviewerName.prefix(2)).uppercased()
        
        // Parámetros para la función RPC
        let params: [String: AnyJSON] = [
            "p_request_id": .string(req.id.uuidString),
            "p_reviewee_id": .string(revieweeId.uuidString),
            "p_reviewer_name": .string(reviewerName),
            "p_reviewer_initials": .string(initials),
            "p_rating": .double(rating),
            "p_comment": .string(comment),
            "p_points_reward": .integer(req.points_reward)
        ]
        
        do {
            try await SupabaseManager.shared.client
                .rpc("procesar_calificacion_y_recompensa", params: params)
                .execute()
            
            // Refrescamos los datos para que el estado de la solicitud cambie a 'calificada' en la UI
            await loadDetails(requestId: req.id)
        } catch {
            print("Error enviando calificación: \(error)")
        }
    }
}
