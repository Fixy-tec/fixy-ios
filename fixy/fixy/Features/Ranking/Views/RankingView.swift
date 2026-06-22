//
//  RankingView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI

struct RankingView: View {
    @State private var viewModel = RankingViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    
                    Text("Ranking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // 1. Tarjeta Principal del Rango Actual
                    currentRankCard
                        .padding(.horizontal, 20)
                    
                    // 2. Carrusel de Todas las Medallas
                    allMedalsSection
                    
                    // 3. Top Estudiantes con Filtros
                    topStudentsSection
                    
                    Spacer().frame(height: 100) // Espacio para el TabBar inferior
                }
            }
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }
    
    // MARK: - Tarjeta Principal
    private var currentRankCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                // Círculo de progreso con la medalla
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.progressPercentage)
                        .stroke(Color("FixyPrimary"), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Image(viewModel.currentMedal.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("TU RANGO ACTUAL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.currentMedal.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        statPill(value: "\(viewModel.currentUserPoints)", label: "Tus puntos")
                        statPill(value: "#\(viewModel.currentUserPosition)", label: "Posicion")
                    }
                }
                Spacer()
            }
            
            // Barra de progreso lineal
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(Color("FixyPrimary"))
                            .frame(width: geometry.size.width * viewModel.progressPercentage, height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(viewModel.currentMedal.minPoints) pts")
                    Spacer()
                    if let next = viewModel.nextMedal {
                        Text("\(next.minPoints) pts")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let next = viewModel.nextMedal {
                    let needed = next.minPoints - viewModel.currentUserPoints
                    Text("\(needed) pts para \(next.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).fontWeight(.bold)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
    }
    
    // MARK: - Carrusel de Medallas
    private var allMedalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star")
                Text("TODAS LAS MEDALLAS")
            }
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.allMedals) { medal in
                        // Usamos un componente separado para manejar la animación individualmente
                        AnimatedMedalCard(
                            medal: medal,
                            isCurrent: medal.id == viewModel.currentMedal.id
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10) // Espacio para que la sombra de la animación no se corte
            }
        }
    }
    
    // MARK: - Top Estudiantes
    private var topStudentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.2")
                Text("TOP ESTUDIANTES")
            }
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            
            // Filtros horizontales
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.studentFilters, id: \.self) { filter in
                        Button(action: {
                            withAnimation { viewModel.selectedFilter = filter }
                        }) {
                            HStack {
                                if let matchedMedal = viewModel.allMedals.first(where: { $0.name == filter }) {
                                    Image(matchedMedal.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                }
                                Text(filter)
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedFilter == filter ? Color("FixyPrimary").opacity(0.15) : Color.clear)
                            .foregroundColor(viewModel.selectedFilter == filter ? Color("FixyPrimary") : .primary)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(viewModel.selectedFilter == filter ? Color("FixyPrimary") : Color.gray.opacity(0.3), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Lista de Estudiantes
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredStudents) { student in
                    studentRow(student)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    private func studentRow(_ student: RankedStudent) -> some View {
        HStack(spacing: 16) {
            // Número o Ícono
            Group {
                if student.position == 1 {
                    Image(systemName: "medal.fill").foregroundColor(.yellow)
                } else if student.position == 2 {
                    Image(systemName: "medal.fill").foregroundColor(.gray)
                } else if student.position == 3 {
                    Image(systemName: "medal.fill").foregroundColor(.orange)
                } else {
                    Text("\(student.position)").fontWeight(.bold).foregroundColor(.secondary)
                }
            }
            .font(.title3)
            .frame(width: 30)
            
            // Iniciales
            Text(student.initials)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(student.isCurrentUser ? Color("FixyPrimary") : .primary)
                .frame(width: 40, height: 40)
                .background(student.isCurrentUser ? Color("FixyPrimary").opacity(0.2) : Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            // Nombre y Puntos
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(student.fullName)
                        .font(.headline)
                    if student.isCurrentUser {
                        Text("(tu)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Text("\(student.points) pts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Medalla en pequeño
            Image(student.medal.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
        .padding()
        .background(student.isCurrentUser ? Color("FixyPrimary").opacity(0.1) : Color(UIColor.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(student.isCurrentUser ? Color("FixyPrimary") : Color.clear, lineWidth: 2)
        )
        .cornerRadius(16)
    }
}

// MARK: - Subvista con Animación (El secreto de la magia al tocar)
struct AnimatedMedalCard: View {
    let medal: FixyMedal
    let isCurrent: Bool
    
    // Estado local para la animación de esta tarjeta específica
    @State private var isWiggling = false
    
    var body: some View {
        VStack(spacing: 8) {
            if isCurrent {
                Text("Tu aqui")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("FixyPrimary"))
                    .clipShape(Capsule())
                    .offset(y: -5)
            } else {
                Spacer().frame(height: 18) // Mantener la misma altura para alinear
            }
            
            Image(medal.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            
            Text(medal.name)
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text(medal.maxPoints == 99999 ? "\(medal.minPoints)+" : "\(medal.minPoints)-\(medal.maxPoints)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 100, height: 140)
        .background(Color(UIColor.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCurrent ? Color("FixyPrimary") : Color.clear, lineWidth: 2)
        )
        .cornerRadius(16)
        // 🌟 LA ANIMACIÓN EXACTA QUE PEDISTE
        .rotationEffect(.degrees(isWiggling ? 3 : 0)) // Tiembla un poco
        .scaleEffect(isWiggling ? 1.05 : 1.0) // Se hace ligeramente más grande
        .shadow(color: isWiggling ? Color.black.opacity(0.15) : Color.clear, radius: 8, x: 0, y: 5) // Sombra de "despegue"
        .onTapGesture {
            // Dispara el temblor con un resorte
            withAnimation(.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0)) {
                isWiggling = true
            }
            // Lo devuelve a la normalidad después de un instante
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    isWiggling = false
                }
            }
        }
    }
}

#Preview {
    RankingView()
}
