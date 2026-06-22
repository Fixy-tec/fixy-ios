//
//  RankingViewModel.swift
//  fixy
//
//  Created by yordan on 21/06/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class RankingViewModel {
    
    // Filtro seleccionado para el carrusel de estudiantes
    var selectedFilter: String = "Todos"
    
    // 1. Catálogo oficial de Medallas (Asegúrate de que los nombres de imagen coincidan con tus assets)
    let allMedals: [FixyMedal] = [
        FixyMedal(name: "Hierro", minPoints: 0, maxPoints: 299, imageName: "hierro"),
        FixyMedal(name: "Bronce", minPoints: 300, maxPoints: 799, imageName: "bronce"),
        FixyMedal(name: "Plata", minPoints: 800, maxPoints: 1799, imageName: "plata"),
        FixyMedal(name: "Oro", minPoints: 1800, maxPoints: 3499, imageName: "oro"),
        FixyMedal(name: "Diamante", minPoints: 3500, maxPoints: 5999, imageName: "diamante"),
        FixyMedal(name: "Maestro", minPoints: 6000, maxPoints: 9999, imageName: "maestro"),
        FixyMedal(name: "Challenger", minPoints: 10000, maxPoints: 99999, imageName: "challenger")
    ]
    
    // 2. Datos del usuario actual simulados
    let currentUserPoints = 4320
    let currentUserPosition = 2
    
    // Calculamos qué medalla tiene el usuario actualmente basado en sus puntos
    var currentMedal: FixyMedal {
        allMedals.first { currentUserPoints >= $0.minPoints && currentUserPoints <= $0.maxPoints } ?? allMedals[0]
    }
    
    // Calculamos cuál es la siguiente medalla
    var nextMedal: FixyMedal? {
        if let currentIndex = allMedals.firstIndex(where: { $0.id == currentMedal.id }), currentIndex + 1 < allMedals.count {
            return allMedals[currentIndex + 1]
        }
        return nil
    }
    
    // Porcentaje de la barra de progreso (0.0 a 1.0)
    var progressPercentage: Double {
        guard let next = nextMedal else { return 1.0 } // Si ya es Challenger, barra llena
        let range = Double(next.minPoints - currentMedal.minPoints)
        let currentProgress = Double(currentUserPoints - currentMedal.minPoints)
        return currentProgress / range
    }
    
    // 3. Base de datos simulada del Top Estudiantes
    private var allStudents: [RankedStudent] = []
    
    init() {
        // Inicializamos los estudiantes (Usamos las medallas del catálogo)
        allStudents = [
            RankedStudent(position: 1, fullName: "Ana Castillo", points: 8240, medal: allMedals[5], isCurrentUser: false),
            RankedStudent(position: 2, fullName: "Yordan Sapacayo", points: 4320, medal: allMedals[4], isCurrentUser: true),
            RankedStudent(position: 3, fullName: "Marco Villanueva", points: 3890, medal: allMedals[4], isCurrentUser: false),
            RankedStudent(position: 4, fullName: "Sofia Rios", points: 2100, medal: allMedals[3], isCurrentUser: false)
        ]
    }
    
    // 4. Lógica de filtrado en tiempo real
    var filteredStudents: [RankedStudent] {
        if selectedFilter == "Todos" {
            return allStudents.sorted { $0.position < $1.position }
        } else {
            return allStudents
                .filter { $0.medal.name == selectedFilter }
                .sorted { $0.position < $1.position }
        }
    }
    
    // Opciones para el filtro horizontal de estudiantes
    var studentFilters: [String] {
        var filters = ["Todos"]
        // Solo mostramos filtros de medallas que realmente tengan estudiantes
        let activeMedals = Set(allStudents.map { $0.medal.name })
        filters.append(contentsOf: allMedals.map { $0.name }.filter { activeMedals.contains($0) })
        return filters
    }
}
