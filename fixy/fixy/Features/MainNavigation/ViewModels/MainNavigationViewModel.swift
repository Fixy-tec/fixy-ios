//
//  MainNavigationViewModel.swift
//  fixy
//
//  Created by yordan on 22/06/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class MainNavigationViewModel {
    // Controla la pestaña activa (arranca siempre en Inicio)
    var selectedTab: MainTab = .inicio
    
    // Aquí a futuro controlaremos notificaciones en la barra
    // var unreadNotificationsCount: Int = 0
    // var unreadMessagesCount: Int = 0
    
    // Función de utilidad para forzar la navegación desde cualquier lado
    func goToTab(_ tab: MainTab) {
        self.selectedTab = tab
    }
}
