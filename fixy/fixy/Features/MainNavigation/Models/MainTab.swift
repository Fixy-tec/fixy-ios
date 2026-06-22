//
//  MainTab.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation

enum MainTab: String, CaseIterable {
    case inicio = "Inicio"
    case solicitudes = "Solicitudes"
    case buscar = "Buscar"
    case ranking = "Ranking"
    case perfil = "Perfil"
    
    // Ícono normal (cuando no está seleccionado)
    var iconName: String {
        switch self {
        case .inicio: return "house"
        case .solicitudes: return "list.clipboard"
        case .buscar: return "magnifyingglass"
        case .ranking: return "chart.line.uptrend.xyaxis"
        case .perfil: return "person"
        }
    }
    
    // Ícono rellenado (cuando sí está seleccionado)
    var selectedIconName: String {
        switch self {
        case .inicio: return "house.fill"
        case .solicitudes: return "list.clipboard.fill"
        case .buscar: return "magnifyingglass" // Lupa no tiene versión "fill"
        case .ranking: return "chart.line.uptrend.xyaxis"
        case .perfil: return "person.fill"
        }
    }
}
