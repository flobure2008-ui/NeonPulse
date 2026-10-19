import SwiftUI

public struct MissionsView: View {
    @ObservedObject var scoreManager = ScoreManager.shared
    @ObservedObject var gameState = GameState.shared
    @Environment(\.presentationMode) var presentationMode
    
    public var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.04, blue: 0.1).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                // Header Bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("MISSIONS CYBER")
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("RÉALISE DES DÉFIS POUR GAGNER DES BITS")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Mission List
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(scoreManager.missions) { mission in
                            MissionCardView(mission: mission)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

private struct MissionCardView: View {
    let mission: Mission
    @ObservedObject var scoreManager = ScoreManager.shared
    
    var progressFraction: Double {
        return min(1.0, Double(mission.currentProgress) / Double(mission.target))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "rhombus.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.cyan)
                        Text("+\(mission.reward) BITS")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                }
                
                Spacer()
                
                if mission.isClaimed {
                    Text("✓ TERMINÉ")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                } else if mission.isCompleted {
                    Button(action: {
                        scoreManager.claimReward(missionId: mission.id)
                    }) {
                        Text("RÉCLAMER")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.yellow)
                            .cornerRadius(8)
                            .shadow(color: .yellow.opacity(0.8), radius: 6)
                    }
                } else {
                    Text("\(mission.currentProgress)/\(mission.target)")
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(mission.isCompleted ? Color.green : Color.cyan)
                        .frame(width: max(0, geo.size.width * CGFloat(progressFraction)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(mission.isCompleted && !mission.isClaimed ? Color.yellow.opacity(0.6) : Color.white.opacity(0.06), lineWidth: 1))
        )
    }
}
