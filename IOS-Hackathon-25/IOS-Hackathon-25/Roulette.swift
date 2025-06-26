import SwiftUI
import AVFoundation

struct RouletteWheelView: View {
    let players: [String] // Accept array of player names instead of just a number
    let onResult: (String) -> Void
    
    @State private var selectedCategories: [String] = [] // Will use actual player names
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var player: AVAudioPlayer? // Sound
    @State private var resultText: String = "Tap to spin!"
    @State private var showWinner = false
    @State private var winnerName: String = ""
    
    // Wheel
    var wheelSize: CGFloat = 350 // Size
    let colors: [Color] = [
        Color(hex: "#ff6600"), // Orange
        Color(hex: "#5c5ce6"), // Purple
        Color(hex: "#ff9900"), // Yellow
        Color(hex: "#dae6c3"), // White
        Color(hex: "#00661a"), // Green
        Color(hex: "#f2ccff")  // Pink
    ]

    var body: some View {
        ZStack {
            // Background
            Image("Bg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Roulette Wheel")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text(resultText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                
                ZStack {
                    // Rotating Wheel with Spin Button
                    GeometryReader { geometry in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        
                        // Arrow
                        VStack {
                            Image(systemName: "arrowtriangle.down.fill")
                                .resizable()
                                .frame(width: 20, height: 30)
                                .foregroundColor(Color(hex: "#ff6600"))
                            Spacer()
                        }.frame(maxWidth: .infinity)
                        
                        // Category segments with borders
                        ZStack {
                            ForEach(selectedCategories.indices, id: \.self) { index in
                                let segmentAngle = 360.0 / Double(selectedCategories.count)
                                let startAngle = Double(index) * segmentAngle
                                let endAngle = startAngle + segmentAngle
                                let midAngle = startAngle + segmentAngle / 2
                                let angle = Angle(degrees: midAngle - 90)

                                // Draw segment lines
                                Path { path in
                                    path.move(to: center)
                                    path.addArc(
                                        center: center,
                                        radius: wheelSize / 2,
                                        startAngle: Angle(degrees: startAngle),
                                        endAngle: Angle(degrees: endAngle),
                                        clockwise: false
                                    )
                                    path.closeSubpath()
                                }
                                .fill(colors[index % colors.count].opacity(0.8))

                                // Category labels inside the slice
                                Text(selectedCategories[index])
                                    .font(.system(size: getFontSize(), weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                    .rotationEffect(Angle(degrees: midAngle > 90 && midAngle < 270 ? midAngle + 180 : midAngle))
                                    .position(
                                        x: center.x + (wheelSize / 3.5) * CGFloat(cos(Angle(degrees: midAngle).radians)),
                                        y: center.y + (wheelSize / 3.5) * CGFloat(sin(Angle(degrees: midAngle).radians))
                                    )
                            }

                            // Center SPIN Button
                            Button(action: {
                                spinNeedle()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#000000"))
                                        .frame(width: wheelSize / 5, height: wheelSize / 5)
                                        .scaleEffect(isSpinning ? 0.8 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: isSpinning)

                                    VStack {
                                        Text("SPIN")
                                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .disabled(isSpinning)
                        }
                        .position(center)
                        .rotationEffect(.degrees(rotation))
                        .animation(.easeOut(duration: 3), value: rotation)
                    }
                    .padding(.bottom)
                    .frame(width: wheelSize + 80, height: wheelSize + 100)
                }
                
                // Players list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Players:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(players, id: \.self) { player in
                            Text(player)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.6))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.4))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Winner Popup
            if showWinner {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("🎉 WINNER! 🎉")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        Text(winnerName)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        
                        Text("Congratulations!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Button("Continue") {
                            showWinner = false
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(color: .yellow, radius: 20)
                }
                .scaleEffect(showWinner ? 1.0 : 0.1)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showWinner)
            }
        }
        .onAppear {
            setupCategories()
        }
        .navigationTitle("Roulette")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Setup categories using actual player names
    private func setupCategories() {
        selectedCategories = players
        resultText = "Ready to spin! \(players.count) players"
    }
    
    // Adjust font size based on number of players
    private func getFontSize() -> CGFloat {
        switch players.count {
        case 1...3:
            return 16
        case 4...6:
            return 14
        case 7...9:
            return 12
        case 10...12:
            return 10
        default:
            return 8
        }
    }
    
    private func playSpinSound() {
        if let soundURL = Bundle.main.url(forResource: "Spin", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                player?.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }
    
    private func spinNeedle() {
        guard !isSpinning else { return }
        isSpinning = true
        playSpinSound()
        
        let fullSpins = Double.random(in: 3...6) * 360
        let extraAngle = Double.random(in: 0..<360)
        let totalRotation = fullSpins + extraAngle

        withAnimation {
            rotation += totalRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let finalNeedleAngle = rotation.truncatingRemainder(dividingBy: 360)
            let angleAtPin = (360 - finalNeedleAngle).truncatingRemainder(dividingBy: 360)

            let result = closestCategory(to: angleAtPin, using: createAngleMap(for: selectedCategories))
            onResult(result)
            winnerName = result
            resultText = "The winner is \(result)!"
            isSpinning = false
            
            // Show winner popup after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showWinner = true
            }
        }
    }

    private func createAngleMap(for categories: [String]) -> [(startAngle: Double, endAngle: Double, category: String)] {
        let anglePerCategory = 360.0 / Double(categories.count)
        return categories.enumerated().map { index, category in
            let startAngle = Double(index) * anglePerCategory
            let endAngle = startAngle + anglePerCategory
            return (startAngle, endAngle, category)
        }
    }

    private func closestCategory(to angle: Double, using angleMap: [(startAngle: Double, endAngle: Double, category: String)]) -> String {
        let normalizedAngle = (angle + 360).truncatingRemainder(dividingBy: 360)
        for (startAngle, endAngle, category) in angleMap {
            if startAngle <= normalizedAngle && normalizedAngle < endAngle {
                return category
            }
        }
        return selectedCategories.randomElement() ?? "Unknown"
    }
}

// REMOVED: Color extension is now in separate file

#Preview {
    RouletteWheelView(players: ["Alice", "Bob", "Charlie", "Diana", "Eve"]) { result in
        print("Selected: \(result)")
    }
}
