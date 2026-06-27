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
    
    // Variables principales
    var searchText: String = ""
    var selectedFilter: String = "Todo" // Todo, Asesorias, Proyectos
    var showAdvancedFilters: Bool = false
    
    // Filtros Avanzados
    var compensationFilter: String = "Todos" // Todos, Con pago, Voluntario
    var difficultyFilter: Int = 0 // 0 = Todas, 1-5
    var selectedTags: Set<String> = []
    
    // Extraemos todos los tags únicos de la base de datos para mostrarlos en el panel
    // Jalamos los tags directamente de nuestro archivo central en Core
    var availableTags: [String] {
        return AppConstants.tags
    }
    
    func fetchRequests() async {
            self.isLoading = true
            do {
                let fetched: [SearchRequestDTO] = try await SupabaseManager.shared.client
                    .from("requests")
                    .select("*, profiles(full_name, medal)")
                    .eq("status", value: "abierta")
                    //.gte("deadline", value: todayString)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                print("Solicitudes totales (sin filtros): \(fetched.count)")
                self.allRequests = fetched
            } catch {
                print("❌ Error: \(error)")
            }
            self.isLoading = false
        }
    
    // Motor de filtrado en tiempo real
    var filteredRequests: [SearchRequestDTO] {
        var result = allRequests
        
        // 1. Filtro Superior (Todo, Asesorias, Proyectos)
        if selectedFilter != "Todo" {
            let filterClean = selectedFilter.lowercased() == "asesorias" ? "asesoria" : "proyecto"
            result = result.filter { $0.type.lowercased() == filterClean }
        }
        
        // 2. Barra de Búsqueda
        if !searchText.isEmpty {
            result = result.filter { request in
                request.title.localizedCaseInsensitiveContains(searchText) ||
                request.technologies.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        // 3. Compensación
        if compensationFilter == "Con pago" {
            result = result.filter { ($0.price ?? 0) > 0 }
        } else if compensationFilter == "Voluntario" {
            result = result.filter { ($0.price ?? 0) == 0 }
        }
        
        // 4. Dificultad
        if difficultyFilter > 0 {
            result = result.filter { $0.difficulty == difficultyFilter }
        }
        
        // 5. Tags (Si selecciona alguno, muestra las solicitudes que tengan al menos 1 coincidencia)
        if !selectedTags.isEmpty {
            result = result.filter { req in
                !selectedTags.isDisjoint(with: Set(req.technologies))
            }
        }
        
        return result
    }
}
