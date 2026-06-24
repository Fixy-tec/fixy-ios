//
//  SearchViewModel.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class SearchViewModel {
    var allRequests: [SearchRequestDTO] = []
    var isLoading: Bool = true
    
    // Variables reactivas en tiempo real
    var searchText: String = ""
    var selectedFilter: String = "Todos"
    
    func fetchRequests() async {
        self.isLoading = true
        do {
            let fetched: [SearchRequestDTO] = try await SupabaseManager.shared.client
                .from("requests")
                .select("*, profiles(full_name, medal)")
                .eq("status", value: "abierta")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.allRequests = fetched
        } catch {
            print("❌ Error al descargar búsquedas: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
    
    // Propiedad calculada que filtra reactivamente en hilos del hilo principal
    var filteredRequests: [SearchRequestDTO] {
        var result = allRequests
        
        // 1. Filtrado por píldora de tipo
        if selectedFilter != "Todos" {
            // Normalizamos para evitar problemas de mayúsculas/minúsculas de la base de datos
            let filterClean = selectedFilter.lowercased() == "asesoria" ? "asesoria" : "proyecto"
            result = result.filter { $0.type.lowercased() == filterClean }
        }
        
        // 2. Filtrado por texto ingresado en tiempo real
        if !searchText.isEmpty {
            result = result.filter { request in
                request.title.localizedCaseInsensitiveContains(searchText) ||
                request.technologies.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        return result
    }
}
