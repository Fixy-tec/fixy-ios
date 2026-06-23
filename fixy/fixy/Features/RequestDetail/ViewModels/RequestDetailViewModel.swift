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
            print("❌ Error cargando detalle de solicitud: \(error)")
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
            print("❌ Error al postular: \(error)")
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
            if let index = applicants.firstIndex(where: { $0.id == applicationId }) {
                applicants[index].status = "aprobado"
                self.request?.status = "en_proceso" // Solo actualizamos localmente para no hacer otro fetch (aunque da error en Swift 6 si es 'let', por eso arriba RequestDetailDTO tiene properties fijas, haremos un reload)
            }
            await loadDetails(requestId: req.id)
            
        } catch {
            print("❌ Error al aceptar postulante: \(error)")
        }
    }
    
    func markAsCompleted() async {
        guard let req = request else { return }
        do {
            try await SupabaseManager.shared.client.from("requests").update(["status": "completada"]).eq("id", value: req.id).execute()
            await loadDetails(requestId: req.id) // Refrescar
        } catch {
            print("❌ Error al completar solicitud: \(error)")
        }
    }
}
