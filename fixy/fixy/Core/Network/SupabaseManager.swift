//
//  SupabaseManager.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import Foundation
import Supabase

final class SupabaseManager {
    // Instancia compartida (Singleton)
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // 1. Extraer credenciales del Info.plist de forma segura
        guard let infoDictionary = Bundle.main.infoDictionary,
              let urlString = infoDictionary["SupabaseURL"] as? String,
              let anonKey = infoDictionary["SupabaseAnonKey"] as? String,
              let url = URL(string: urlString) else {
            fatalError("Error crítico: Faltan las credenciales de Supabase en Secrets.xcconfig o no están en el Info.plist")
        }
        
        // 2. Inicializar el cliente
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
        
        print("Supabase Manager inicializado correctamente")
    }
}
