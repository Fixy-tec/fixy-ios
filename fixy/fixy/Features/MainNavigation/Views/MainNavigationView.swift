//
//  MainNavigationView.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import SwiftUI

struct MainNavigationView: View {
    @State private var viewModel = MainNavigationViewModel()
    
    var body: some View {
        // TabView enlazado a la variable de nuestro ViewModel
        TabView(selection: $viewModel.selectedTab) {
            
            // 1. INICIO
                        HomeView() // 👈 Cambia el Text("Vista de Inicio") por esto
                            .tabItem {
                                Image(systemName: viewModel.selectedTab == .inicio ? MainTab.inicio.selectedIconName : MainTab.inicio.iconName)
                                Text(MainTab.inicio.rawValue)
                            }
                            .tag(MainTab.inicio)
            
            // 2. SOLICITUDES
            RequestsView()
                .tabItem {
                    Image(systemName: viewModel.selectedTab == .solicitudes ? MainTab.solicitudes.selectedIconName : MainTab.solicitudes.iconName)
                    Text(MainTab.solicitudes.rawValue)
                }
                .tag(MainTab.solicitudes)
            
            // 3. BUSCAR
            SearchView()
                .tabItem {
                    Image(systemName: MainTab.buscar.iconName)
                    Text(MainTab.buscar.rawValue)
                }
                .tag(MainTab.buscar)
            
            // 4. RANKING
            RankingView()
                .tabItem {
                    Image(systemName: MainTab.ranking.iconName)
                    Text(MainTab.ranking.rawValue)
                }
                .tag(MainTab.ranking)
            
            // 5. PERFIL
            ProfileView()
                .tabItem {
                    Image(systemName: viewModel.selectedTab == .perfil ? MainTab.perfil.selectedIconName : MainTab.perfil.iconName)
                    Text(MainTab.perfil.rawValue)
                }
                .tag(MainTab.perfil)
        }
        // Aplica el color principal de la app al ítem seleccionado
        .tint(Color("FixyPrimary"))
        .environment(viewModel)
    }
}

#Preview {
    MainNavigationView()
}
