//
//  CreateRequestViewModel.swift
//  fixy
//
//  Created by yordan on 21/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class CreateRequestViewModel {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    func createRequest(
        type: String,
        title: String,
        description: String,
        tags: Set<String>,
        difficulty: Int,
        deadline: Date,
        priceString: String
    ) async -> Bool {
        self.isLoading = true
        self.errorMessage = nil
        
        // 1. Validaciones básicas
        guard !title.isEmpty, !description.isEmpty else {
            self.errorMessage = "El título y la descripción son obligatorios."
            self.isLoading = false
            return false
        }
        
        // 2. Obtener el ID del usuario actual
        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
            self.errorMessage = "Error de sesión. Vuelve a iniciar sesión."
            self.isLoading = false
            return false
        }
        
        // 3. Formatear los datos
        let tagsArray = Array(tags)
        let calculatedPoints = difficulty * 60
        
        // Convertir el precio de String a Double de forma segura (si está vacío, se envía nil)
        let formattedPrice: Double? = {
            let cleanString = priceString.replacingOccurrences(of: ",", with: ".")
            return cleanString.isEmpty ? nil : Double(cleanString)
        }()
        
        // Formatear la fecha para que Supabase la entienda como DATE (YYYY-MM-DD)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: deadline)
        
        // 4. Preparar la estructura para insertar
        let requestData = RequestInsert(
            creatorId: userId,
            type: type,
            title: title,
            description: description,
            technologies: tagsArray,
            difficulty: difficulty,
            deadline: dateString,
            price: formattedPrice,
            pointsReward: calculatedPoints
        )
        
        // 5. Enviar a Supabase
        do {
            try await SupabaseManager.shared.client
                .from("requests")
                .insert(requestData)
                .execute()
            
            self.isLoading = false
            return true // ¡Éxito!
            
        } catch {
            self.errorMessage = "Error al publicar: \(error.localizedDescription)"
            self.isLoading = false
            return false
        }
    }
}
