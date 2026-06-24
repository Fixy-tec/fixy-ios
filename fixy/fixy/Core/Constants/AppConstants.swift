//
//  AppConstants.swift
//  fixy
//
//  Created by yordan on 24/06/26.
//

import Foundation

struct AppConstants {
    // Definimos la lista como 'static' para poder llamarla desde cualquier parte de la app
    // sin tener que inicializar esta estructura.
    static let tags: [String] = [
        // Lenguajes
        "Python", "Dart", "Java", "JavaScript", "TypeScript", "C++", "C#", "Go", "Rust", "SQL",
        
        // Frameworks / Plataformas
        "Flutter", "React", "Next.js", "Node.js", "Spring Boot", "Django", "Firebase", "Supabase",
        
        // Áreas
        "Algoritmos", "Estructuras", "Bases de datos", "Redes", "Linux", "Cloud", "DevOps", "Seguridad", "Machine Learning", "Diseño UX", "Diseño UI",
        
        // Hardware / IoT
        "Arduino", "Raspberry Pi", "Electronica", "Domotica",
        
        // Cursos clásicos
        "Matematicas", "Calculo", "Algebra", "Estadistica", "Fisica", "Logica de programacion"
    ]
}
