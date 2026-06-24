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
    
    // Paso 3
    @State private var difficultyLevel: Int = 3
    @State private var deadline: Date = Date()
    @State private var price: String = ""
    
    @State private var showErrorAlert = false
    
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
            .alert("Atención", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Ocurrió un error inesperado.")
            }
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
                    Text("Atrás")
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
                HStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(currentStep == 3 ? "Publicar solicitud" : "Continuar")
                    }
                }
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(currentStep == 3 ? Color.teal : Color("FixyPrimary"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading) // Previene doble clic
        }
        .padding(20)
    }
    
    // MARK: - Paso 1: Tipo de Solicitud
    
    private var stepOneType: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                headerText(title: "¿Qué tipo de solicitud es?", subtitle: "Esto define cómo otros estudiantes verán tu publicación.")
                
                // Tarjeta Asesoría
                typeCard(
                    title: "Asesoria",
                    description: "Busca ayuda con un curso, revisión de trabajo, repaso de examen o retroalimentación.",
                    icon: "book.pages",
                    isSelected: selectedType == "Asesoria"
                ) {
                    selectedType = "Asesoria"
                }
                
                // Tarjeta Proyecto (Ícono arreglado a paperplane)
                typeCard(
                    title: "Proyecto",
                    description: "Busca socios para desarrollar un proyecto académico, personal o de emprendimiento.",
                    icon: "paperplane.fill",
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
                headerText(title: "Cuéntanos más", subtitle: "Mientras más detallado, mejores postulantes atraerás.")
                
                // Campo de Título
                VStack(alignment: .trailing, spacing: 4) {
                    VStack(alignment: .leading) {
                        Text("Título").font(.caption).foregroundColor(.secondary)
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
                        Text("Descripción").font(.caption).foregroundColor(.secondary)
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
                
                // 🌟 Tags requeridos usando la constante global del ViewModel
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tecnologías o áreas (Máximo 5)")
                        .font(.headline)
                    
                    FlowLayout(spacing: 10) {
                        ForEach(viewModel.availableTags, id: \.self) { tag in
                            let isSelected = viewModel.selectedTags.contains(tag)
                            
                            Button(action: {
                                if isSelected {
                                    viewModel.selectedTags.remove(tag)
                                } else {
                                    // Limita a 5 tags por solicitud
                                    if viewModel.selectedTags.count < 5 {
                                        viewModel.selectedTags.insert(tag)
                                    }
                                }
                            }) {
                                Text(tag)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Color.blue.opacity(0.12) : Color(UIColor.systemBackground))
                                    .foregroundColor(isSelected ? Color.blue : .primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Paso 3: Condiciones
        
    private var stepThreeConditions: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerText(title: "Condiciones", subtitle: "Define la dificultad, el plazo y si hay compensación económica.")
                
                // Nivel de Dificultad
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nivel de dificultad").font(.headline)
                    
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
                            .frame(maxWidth: .infinity)
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
                    Text("Fecha límite estimada").font(.headline)
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
                    Text("Beneficio económico (opcional)").font(.headline)
                    TextField("0.00", text: $price)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    
                    Text("Si lo dejas vacío se mostrará como \"Voluntario / Solo Puntos\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Tarjeta de Resumen Final
                VStack(spacing: 12) {
                    Text("Resumen").font(.headline).foregroundColor(Color("FixyPrimary")).frame(maxWidth: .infinity, alignment: .leading)
                    
                    summaryRow(title: "Tipo:", value: selectedType)
                    summaryRow(title: "Título:", value: title.isEmpty ? "Sin título" : title)
                    
                    // 🌟 Leemos los tags del ViewModel
                    summaryRow(title: "Tags:", value: viewModel.selectedTags.isEmpty ? "Ninguno" : viewModel.selectedTags.joined(separator: ", "))
                    
                    summaryRow(title: "Nivel:", value: "Nivel \(difficultyLevel) (+\(difficultyLevel * 60) pts)")
                    summaryRow(title: "Límite:", value: deadline.formatted(date: .abbreviated, time: .omitted))
                    
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
            // Validación extra para no avanzar de paso si el título está vacío
            if currentStep == 2 && (title.isEmpty || description.isEmpty) {
                viewModel.errorMessage = "El título y la descripción son obligatorios."
                showErrorAlert = true
                return
            }
            withAnimation { currentStep += 1 }
        } else {
            Task {
                // 🌟 Llamada actualizada SIN el parámetro 'tags'
                let success = await viewModel.createRequest(
                    type: selectedType,
                    title: title,
                    description: description,
                    difficulty: difficultyLevel,
                    deadline: deadline,
                    priceString: price
                )
                
                if success {
                    dismiss()
                } else {
                    showErrorAlert = true
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
