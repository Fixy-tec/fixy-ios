//
//  FixyTheme.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

extension Color {
    // ⚠️ NOTA: fixyPrimary, fixySecondary, etc., ya NO están aquí
    // porque Xcode 16 los genera automáticamente desde Assets.xcassets.
    	
    // Colores semánticos del sistema de Apple (adaptables claro/oscuro)
    static let fixyBackground = Color(UIColor.systemBackground)
    static let fixySurface = Color(UIColor.secondarySystemBackground)
    static let fixyText = Color(UIColor.label)
    static let fixySubtext = Color(UIColor.secondaryLabel)
}
