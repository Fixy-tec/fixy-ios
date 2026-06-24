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
    // Todos los datos crudos de Supabase
    var allRequests: [SearchRequestDTO] = []
    var isLoading: Bool = true
    
    // Variables de filtrado para la Vista
    var searchText: String = ""
    var selectedFilter: String = "Todos" // Puede ser "Todos", "Asesoria", "Proyecto"
    
    func fetchRequests() async {
        self.isLoading = true
        do {
            // Hacemos un JOIN con profiles para tener el nombre del creador
            let fetched: [SearchRequestDTO] = try await SupabaseManager.shared.client
                .from("requests")
                .select("*, profiles(full_name, medal)")
                .eq("status", value: "abierta") // Solo mostramos las que se pueden postular
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.allRequests = fetched
        } catch {
            print("❌ Error al cargar las búsquedas: \(error)")
        }
        self.isLoading = false
    }
    
    // Esta propiedad calculada devuelve la lista filtrada en tiempo real
    var filteredRequests: [SearchRequestDTO] {
        var result = allRequests
        
        // 1. Filtrar por Tipo (Píldoras superiores)
        if selectedFilter != "Todos" {
            result = result.filter { $0.type.lowercased() == selectedFilter.lowercased() }
        }
        
        // 2. Filtrar por Texto (Barra de búsqueda)
        if !searchText.isEmpty {
            result = result.filter { request in
                request.title.localizedCaseInsensitiveContains(searchText) ||
                request.technologies.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        return result
    }
}
