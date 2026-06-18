//
//  ViewModifiers.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct PrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.fixyPrimary)
            .cornerRadius(12)
            .shadow(color: Color.fixyPrimary.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}

extension View {
    func fixyPrimaryButtonStyle() -> some View {
        self.modifier(PrimaryButtonModifier())
    }
}
