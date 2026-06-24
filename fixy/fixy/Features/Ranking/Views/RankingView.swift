//
//  RankingView.swift
//  fixy
//
//  Created by yordan on 18/06/26.
//

import SwiftUI
import Supabase

struct RankingView: View {
    @State private var viewModel = RankingViewModel()
    
    // Animación de flotabilidad (Banner)
    @State private var isAnimatingMedals = false
    // 🌟 Animación de toque (Carrusel)
    @State private var tappedMedal: String? = nil
    
    // 🌟 Lista de filtros completa y en orden
    let rankFilters = ["Todos", "Challenger", "Maestro", "Diamante", "Oro", "Plata", "Bronce", "Hierro"]
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Calculando ranking...")
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            currentRankBanner
                            medalsCarousel
                            topStudentsSection
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Ranking")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(UIColor.secondarySystemBackground).ignoresSafeArea())
            .task { await viewModel.fetchRanking() }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    isAnimatingMedals = true
                }
            }
        }
    }
    
    // MARK: - 1. Tarjeta de Rango Actual (Banner Superior)
    private var currentRankBanner: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: viewModel.progressPercentage)
                        .stroke(Color("FixyPrimary"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Image((viewModel.currentUser?.medal ?? "diamante").lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .shadow(color: Color("FixyPrimary").opacity(isAnimatingMedals ? 0.6 : 0.2), radius: isAnimatingMedals ? 10 : 4)
                        .offset(y: isAnimatingMedals ? -3 : 3)
                }
                .frame(width: 90, height: 90)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("TU RANGO ACTUAL").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                    Text(viewModel.currentTier?.name ?? "Rango").font(.title).fontWeight(.bold)
                    HStack(spacing: 12) {
                        VStack {
                            Text("\(viewModel.currentUser?.total_points ?? 0)").font(.headline).fontWeight(.bold)
                            Text("Tus puntos").font(.caption2).foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color(UIColor.tertiarySystemBackground)).cornerRadius(10)
                        
                        VStack {
                            Text("#\(viewModel.currentUserPosition)").font(.headline).fontWeight(.bold)
                            Text("Posicion").font(.caption2).foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color(UIColor.tertiarySystemBackground)).cornerRadius(10)
                    }
                }
                Spacer()
            }
            
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color(UIColor.tertiarySystemBackground)).frame(height: 8)
                        RoundedRectangle(cornerRadius: 4).fill(Color("FixyPrimary"))
                            .frame(width: max(0, geometry.size.width * viewModel.progressPercentage), height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(viewModel.currentTier?.minPoints ?? 0) pts")
                    Spacer()
                    if let next = viewModel.nextTier {
                        Text("\(viewModel.pointsToNextRank) pts para \(next.name)").foregroundColor(.secondary)
                        Spacer()
                        Text("\(next.minPoints) pts")
                    } else {
                        Text("Rango Máximo").foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .font(.caption)
            }
        }
        .padding(20).background(Color(UIColor.systemBackground)).cornerRadius(24).padding(.horizontal)
    }
    
    // MARK: - 2. Carrusel de Todas las Medallas
    private var medalsCarousel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star")
                Text("TODAS LAS MEDALLAS").font(.caption).fontWeight(.bold).tracking(1)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { // 🌟 Reducimos el espaciado
                    ForEach(viewModel.allTiers, id: \.name) { tier in
                        let isCurrentTier = viewModel.currentTier?.name == tier.name
                        let isTapped = tappedMedal == tier.name
                        
                        VStack(spacing: 10) {
                            if isCurrentTier {
                                Text("Tu aqui")
                                    .font(.system(size: 10, weight: .bold)) // Letra más pequeña
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color("FixyPrimary"))
                                    .clipShape(Capsule())
                            } else {
                                Spacer().frame(height: 20)
                            }
                            
                            Image(tier.name.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45) // 🌟 Imagen un poco más chica
                                // 🌟 EFECTO DE ANIMACIÓN: Sombreado dinámico y giro de lado a lado
                                .shadow(color: isTapped ? Color("FixyPrimary").opacity(0.8) : Color.clear, radius: isTapped ? 15 : 0)
                                .rotationEffect(.degrees(isTapped ? 15 : 0))
                                .animation(.spring(response: 0.2, dampingFraction: 0.2), value: isTapped)
                            
                            VStack(spacing: 2) {
                                Text(tier.name).font(.subheadline).fontWeight(.bold)
                                Text(tier.rangeText).font(.caption2).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 14)
                        .frame(width: 105) // 🌟 Reducimos el ancho de las tarjetas
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isCurrentTier ? Color("FixyPrimary") : Color.gray.opacity(0.3), lineWidth: isCurrentTier ? 2 : 1)
                        )
                        // 🌟 GESTO DE TOQUE
                        .onTapGesture {
                            tappedMedal = tier.name
                            // Vuelve a su estado original después de un instante para dar sensación de "rebote"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                tappedMedal = nil
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
    
    // MARK: - 3. Top Estudiantes
    private var topStudentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.2")
                Text("TOP ESTUDIANTES").font(.caption).fontWeight(.bold).tracking(1)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal)
            
            // 🌟 Píldoras de filtrado actualizadas
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(rankFilters, id: \.self) { rank in
                        Button(action: { withAnimation { viewModel.selectedFilter = rank } }) {
                            HStack(spacing: 6) {
                                if rank == "Todos" {
                                    Image(systemName: "person.3.fill").font(.caption)
                                } else {
                                    Image(rank.lowercased()).resizable().frame(width: 16, height: 16)
                                }
                                Text(rank)
                            }
                            .font(.subheadline).fontWeight(.medium)
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(viewModel.selectedFilter == rank ? Color(UIColor.systemBackground) : Color.clear)
                            .foregroundColor(viewModel.selectedFilter == rank ? .primary : .secondary)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(viewModel.selectedFilter == rank ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1))
                            .shadow(color: Color.black.opacity(viewModel.selectedFilter == rank ? 0.05 : 0), radius: 5, y: 2)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.filteredStudents.enumerated()), id: \.element.id) { index, student in
                    let isMe = SupabaseManager.shared.client.auth.currentUser?.id == student.id
                    studentRow(position: index + 1, student: student, isMe: isMe)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func studentRow(position: Int, student: RankingUserDTO, isMe: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "medal.fill")
                .foregroundColor(position == 1 ? .yellow : position == 2 ? .gray : position == 3 ? .brown : .secondary.opacity(0.5))
                .font(.title3)
                .frame(width: 30)
            
            let nameStr = student.full_name ?? "Estudiante"
            Text(String(nameStr.prefix(2)).uppercased())
                .font(.caption).fontWeight(.bold)
                .foregroundColor(Color("FixyPrimary"))
                .frame(width: 40, height: 40)
                .background(Color("FixyPrimary").opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(nameStr).font(.subheadline).fontWeight(.bold)
                    if isMe {
                        Text("(tú)").font(.subheadline).fontWeight(.bold).foregroundColor(.primary)
                    }
                }
                Text("\(student.total_points ?? 0) pts").font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image((student.medal ?? "Hierro").lowercased())
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isMe ? Color("FixyPrimary") : Color.clear, lineWidth: 2))
    }
}

#Preview {
    RankingView()
}
