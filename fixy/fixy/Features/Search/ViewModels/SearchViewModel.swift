//
//  SearchViewModel.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class SearchViewModel {
    // Variables de estado que lee la vista
    var searchText: String = ""
    var selectedFilter: String = "Todo"
    let filters: [String] = ["Todo", "Asesorias", "Proyectos"]
    
    // Base de datos simulada usando el modelo FixyRequest
    private var allRequests: [FixyRequest] = [
        FixyRequest(type: "Asesoria", points: 400, title: "Gufugigufugufif", technologies: ["Node.js", "Java", "Matematicas", "Fisica", "Flutter"], creatorName: "Hhhw", creatorAvatar: "avatar_6", creatorMedal: "Hierro", price: 996.00, expiration: "Vence manana", applicants: 0),
        FixyRequest(type: "Proyecto", points: 180, title: "Hola ayuda porfa fast", technologies: ["Raspberry Pi", "Node.js", "Fisica", "Python", "React", "Linux", "Next.js"], creatorName: "Ana Castillo", creatorAvatar: "avatar_2", creatorMedal: "Bronce", price: nil, expiration: "Vence en 2 dias", applicants: 2),
        FixyRequest(type: "Asesoria", points: 250, title: "Ayuda con base de datos en SQL", technologies: ["SQL", "Supabase", "Logica de programacion"], creatorName: "Carlos Dev", creatorAvatar: "avatar_3", creatorMedal: "Plata", price: 50.00, expiration: "Vence hoy", applicants: 1)
    ]
    
    // Propiedad calculada que filtra la lista en tiempo real
    var filteredRequests: [FixyRequest] {
        var result = allRequests
        
        // 1. Filtrar por categorías
        if selectedFilter != "Todo" {
            let typeToMatch = selectedFilter == "Asesorias" ? "Asesoria" : "Proyecto"
            result = result.filter { $0.type == typeToMatch }
        }
        
        // 2. Filtrar por la barra de búsqueda
        if !searchText.isEmpty {
            result = result.filter { request in
                let titleMatch = request.title.localizedCaseInsensitiveContains(searchText)
                let techMatch = request.technologies.contains { $0.localizedCaseInsensitiveContains(searchText) }
                return titleMatch || techMatch
            }
        }
        
        return result
    }
}
