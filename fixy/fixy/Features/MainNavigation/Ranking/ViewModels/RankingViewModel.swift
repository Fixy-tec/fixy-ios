//
//  RankingViewModel.swift
//  fixy
//
//  Created by yordan on 21/06/26.
//

import Foundation
import Supabase
import SwiftUI

@Observable
@MainActor
final class RankingViewModel {
    var allStudents: [RankingUserDTO] = []
    var isLoading: Bool = true
    
    var currentUser: RankingUserDTO?
    var currentUserPosition: Int = 0
    
    // 🌟 1. Cambiamos el filtro inicial a "Todos"
    var selectedFilter: String = "Todos"
    
    let allTiers: [MedalTier] = [
        MedalTier(name: "Hierro", minPoints: 0, maxPoints: 499),
        MedalTier(name: "Bronce", minPoints: 500, maxPoints: 999),
        MedalTier(name: "Plata", minPoints: 1000, maxPoints: 1999),
        MedalTier(name: "Oro", minPoints: 2000, maxPoints: 3499),
        MedalTier(name: "Diamante", minPoints: 3500, maxPoints: 5999),
        MedalTier(name: "Maestro", minPoints: 6000, maxPoints: 9999),
        MedalTier(name: "Challenger", minPoints: 10000, maxPoints: nil)
    ]
    
    func fetchRanking() async {
        self.isLoading = true
        guard let myId = SupabaseManager.shared.client.auth.currentUser?.id else { return }
        
        do {
            let fetched: [RankingUserDTO] = try await SupabaseManager.shared.client
                .from("profiles")
                .select("id, full_name, total_points, medal")
                .order("total_points", ascending: false)
                .execute()
                .value
            
            self.allStudents = fetched
            
            if let index = fetched.firstIndex(where: { $0.id == myId }) {
                self.currentUser = fetched[index]
                self.currentUserPosition = index + 1
            }
        } catch {
            print("Error cargando ranking: \(error)")
        }
        self.isLoading = false
    }
    
    // 🌟 2. Lógica actualizada para aceptar "Todos"
    var filteredStudents: [RankingUserDTO] {
        if selectedFilter == "Todos" {
            return allStudents
        }
        return allStudents.filter { ($0.medal ?? "Hierro").lowercased() == selectedFilter.lowercased() }
    }
    
    // MARK: - Cálculos de Progreso (Para el Banner Superior)
    
    var currentTier: MedalTier? {
        let pts = currentUser?.total_points ?? 0
        return allTiers.first { pts >= $0.minPoints && (pts <= ($0.maxPoints ?? Int.max)) }
    }
    
    var nextTier: MedalTier? {
        guard let current = currentTier, let index = allTiers.firstIndex(of: current) else { return nil }
        return index + 1 < allTiers.count ? allTiers[index + 1] : nil
    }
    
    var progressPercentage: Double {
        guard let current = currentTier, let max = current.maxPoints else { return 1.0 }
        let pts = Double(currentUser?.total_points ?? 0)
        let min = Double(current.minPoints)
        let range = Double(max) - min
        return max > 0 ? (pts - min) / range : 1.0
    }
    
    var pointsToNextRank: Int {
        guard let next = nextTier else { return 0 }
        return next.minPoints - (currentUser?.total_points ?? 0)
    }
}
