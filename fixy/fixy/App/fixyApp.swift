//
//  fixyApp.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI
import Supabase

@main
struct fixyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // En fixyApp.swift
            .onOpenURL { url in
                SupabaseManager.shared.client.auth.handle(url)
                print("URL de Google procesada")
            }
        }
    }
}
