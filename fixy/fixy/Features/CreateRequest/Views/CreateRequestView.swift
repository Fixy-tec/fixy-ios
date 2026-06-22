//
//  CreateRequestView.swift
//  fixy
//
//  Created by yordan on 21/06/26.
//

import SwiftUI

struct CreateRequestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 1
    @State private var viewModel = CreateRequestViewModel()
    
    // MARK: - Estado de Datos (Formulario)
    
    // Paso 1
    @State private var selectedType: String = "Asesoria"
    
    // Paso 2
    @State private var title: String = ""
    @State private var description: String = ""
    let allTechs = ["TypeScript", "Supabase", "SQL", "Spring Boot", "Seguridad", "Rust", "Redes", "React", "Raspberry Pi", "Python", "Node.js"]
    @State private var selectedTags: Set<String> = []
    
    // Paso 3
    @State private var difficultyLevel: Int = 3
    @State private var deadline: Date = Date()
    @State private var price: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Header Personalizado
                customHeader
                
                // Barra de progreso
                progressBar
                
                // Contenido dinámico
                TabView(selection: $currentStep) {
                    stepOneType.tag(1)
                    stepTwoDetails.tag(2)
                    stepThreeConditions.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Botones Inferiores
                bottomNavigation
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Componentes de Navegación Superiores e Inferiores
    
    private var customHeader: some View {
        HStack {
            Button(action: goBack) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Text("Crear solicitud — paso \(currentStep)...")
                .font(.title3)
                .padding(.leading, 8)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { step in
                Rectangle()
                    .fill(step <= currentStep ? Color("FixyPrimary") : Color.gray.opacity(0.2))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
    
    private var bottomNavigation: some View {
        HStack {
            if currentStep > 1 {
                Button(action: goBack) {
                    Text("Atras")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            Button(action: goNext) {
                Text(currentStep == 3 ? "Publicar solicitud" : "Continuar")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(currentStep == 3 ? Color.teal : Color("FixyPrimary"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(20)
    }
    
    // MARK: - Paso 1: Tipo de Solicitud
    
    private var stepOneType: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerText(title: "Que tipo de solicitud es?", subtitle: "Esto define como otros estudiantes veran tu publicacion.")
                
                // Tarjeta Asesoría
                typeCard(
                    title: "Asesoria",
                    description: "Busca ayuda con un curso, revision de trabajo, repaso de examen o retroalimentacion.",
                    icon: "book.pages",
                    isSelected: selectedType == "Asesoria"
                ) {
                    selectedType = "Asesoria"
                }
                
                // Tarjeta Proyecto
                typeCard(
                    title: "Proyecto",
                    description: "Busca socios para desarrollar un proyecto academico, personal o de emprendimiento.",
                    icon: "rocket",
                    isSelected: selectedType == "Proyecto"
                ) {
                    selectedType = "Proyecto"
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Paso 2: Detalles
    
    private var stepTwoDetails: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerText(title: "Cuentanos mas", subtitle: "Mientras mas detallado, mejores postulantes atraeras.")
                
                // Campo de Título
                VStack(alignment: .trailing, spacing: 4) {
                    VStack(alignment: .leading) {
                        Text("Titulo").font(.caption).foregroundColor(.secondary)
                        TextField("Ej. Ayuda con una consulta SQL", text: $title)
                            .onChange(of: title) { oldValue, newValue in
                                if newValue.count > 80 { title = String(newValue.prefix(80)) }
                            }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Text("\(title.count)/80").font(.caption).foregroundColor(.secondary)
                }
                
                // Campo de Descripción
                VStack(alignment: .trailing, spacing: 4) {
                    VStack(alignment: .leading) {
                        Text("Descripcion").font(.caption).foregroundColor(.secondary)
                        TextEditor(text: $description)
                            .frame(height: 120)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .onChange(of: description) { oldValue, newValue in
                                if newValue.count > 1000 { description = String(newValue.prefix(1000)) }
                            }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Text("\(description.count)/1000").font(.caption).foregroundColor(.secondary)
                }
                
                // Tags requeridos usando el FlowLayout creado anteriormente
                Text("Tags requeridos").font(.headline)
                
                FlowLayout(spacing: 10) {
                    ForEach(allTechs, id: \.self) { tech in
                        let isSelected = selectedTags.contains(tech)
                        HStack(spacing: 4) {
                            if isSelected {
                                Image(systemName: "checkmark").font(.system(size: 10))
                            }
                            Text(tech)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color("FixyPrimary").opacity(0.15) : Color.clear)
                        .foregroundColor(isSelected ? Color("FixyPrimary") : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color("FixyPrimary") : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onTapGesture {
                            if isSelected { selectedTags.remove(tech) } else { selectedTags.insert(tech) }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Paso 3: Condiciones
        
        private var stepThreeConditions: some View {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerText(title: "Condiciones", subtitle: "Define la dificultad, el plazo y si hay compensacion economica.")
                    
                    // Nivel de Dificultad
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nivel de dificultad").font(.headline)
                        
                        // 🌟 Cambio aquí: HStack con spacing 0 y botones expandidos al máximo ancho
                        HStack(spacing: 0) {
                            ForEach(1...5, id: \.self) { level in
                                Button(action: { difficultyLevel = level }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: difficultyLevel >= level ? "bolt.fill" : "bolt")
                                        Text("\(level)").font(.headline)
                                    }
                                    .foregroundColor(difficultyLevel == level ? Color("FixyPrimary") : .gray)
                                    .frame(width: 50, height: 50)
                                    .background(difficultyLevel == level ? Color("FixyPrimary").opacity(0.15) : Color.clear)
                                    .overlay(Circle().stroke(difficultyLevel == level ? Color("FixyPrimary") : Color.gray.opacity(0.3), lineWidth: 2))
                                    .clipShape(Circle())
                                }
                                .frame(maxWidth: .infinity) // Esto distribuye los círculos perfectamente
                            }
                        }
                        
                        HStack {
                            Text(difficultyText(for: difficultyLevel))
                            Spacer()
                            Text("+\(difficultyLevel * 60) pts base")
                                .fontWeight(.bold)
                                .foregroundColor(.teal)
                        }
                        .font(.subheadline)
                    }
                    
                    // Fecha Límite
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fecha limite estimada").font(.headline)
                        HStack {
                            Image(systemName: "calendar")
                            DatePicker("", selection: $deadline, displayedComponents: .date)
                                .labelsHidden()
                            Spacer()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    
                    // Beneficio Económico
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Beneficio economico (opcional)").font(.headline)
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        
                        Text("Si lo dejas vacio se mostrara como \"Voluntario / Solo Puntos\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Tarjeta de Resumen Final Actualizada
                    VStack(spacing: 12) {
                        Text("Resumen").font(.headline).foregroundColor(Color("FixyPrimary")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        summaryRow(title: "Tipo:", value: selectedType)
                        summaryRow(title: "Titulo:", value: title.isEmpty ? "Sin titulo" : title)
                        summaryRow(title: "Tags:", value: selectedTags.isEmpty ? "Ninguno" : selectedTags.joined(separator: ", "))
                        
                        // 🌟 Nuevos campos en el resumen
                        summaryRow(title: "Nivel:", value: "Nivel \(difficultyLevel) (+\(difficultyLevel * 60) pts)")
                        summaryRow(title: "Limite:", value: deadline.formatted(date: .abbreviated, time: .omitted))
                        
                        // Lógica para mostrar precio o voluntario
                        let cleanPrice = price.replacingOccurrences(of: ",", with: ".")
                        if let priceValue = Double(cleanPrice), priceValue > 0 {
                            summaryRow(title: "Pago:", value: "S/ \(String(format: "%.2f", priceValue))")
                        } else {
                            summaryRow(title: "Pago:", value: "Voluntario")
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(16)
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    
    // MARK: - Componentes Reutilizables y Funciones
    
    private func headerText(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.title).fontWeight(.bold).foregroundColor(.primary)
            Text(subtitle).font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.bottom, 8)
    }
    
    private func typeCard(title: String, description: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? Color("FixyPrimary") : .gray)
                    .frame(width: 50, height: 50)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundColor(.primary)
                    Text(description).font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("FixyPrimary"))
                        .font(.title3)
                }
            }
            .padding()
            .background(isSelected ? Color("FixyPrimary").opacity(0.1) : Color(UIColor.secondarySystemBackground))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color("FixyPrimary") : Color.clear, lineWidth: 2))
            .cornerRadius(16)
        }
    }
    
    private func summaryRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title).foregroundColor(.secondary).frame(width: 60, alignment: .leading)
            Text(value).fontWeight(.medium).foregroundColor(.primary)
            Spacer()
        }
        .font(.subheadline)
    }
    
    private func difficultyText(for level: Int) -> String {
        switch level {
        case 1: return "Muy Fácil"
        case 2: return "Fácil"
        case 3: return "Media"
        case 4: return "Difícil"
        case 5: return "Muy Difícil"
        default: return "Media"
        }
    }
    
    private func goNext() {
            if currentStep < 3 {
                withAnimation { currentStep += 1 }
            } else {
                // Estamos en el paso 3 y el usuario presionó "Publicar solicitud"
                Task {
                    let success = await viewModel.createRequest(
                        type: selectedType,
                        title: title,
                        description: description,
                        tags: selectedTags,
                        difficulty: difficultyLevel,
                        deadline: deadline,
                        priceString: price
                    )
                    
                    if success {
                        // Si se guardó en la base de datos, cerramos el modal
                        dismiss()
                    }
                }
            }
        }
    
    private func goBack() {
        if currentStep > 1 {
            withAnimation { currentStep -= 1 }
        } else {
            dismiss()
        }
    }
}

#Preview {
    CreateRequestView()
}
