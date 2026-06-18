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
              let url = URL(string: "https://\(urlString)") else {
              fatalError("🚨 Error crítico: Faltan las credenciales de Supabase")
        }
        
        // 2. Inicializar el cliente con la nueva configuración de Auth
                self.client = SupabaseClient(
                    supabaseURL: url,
                    supabaseKey: anonKey,
                    options: SupabaseClientOptions(
                        auth: .init(emitLocalSessionAsInitialSession: true)
                    )
                )
                
                print("✅ Supabase Manager inicializado correctamente")
    }
}
