import SwiftUI
import AVFoundation

struct RouletteWheelView: View {
    let number: Int
    
    
    let onResult: (String) -> Void
    
    @State private var selectedCategories: [String] = [] // Randomly choose 20 options
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var player: AVAudioPlayer? // Sound
    
    @State private var resultText: String = "Tap to spin!"
    
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
    
    func generatePlayerArray(count: Int) -> [String] {
        return (1...count).map { "player \($0)" }
    }
     
//    lazy var allCategories: [String] = generatePlayerArray(count: number)

    var body: some View {
        VStack {
            Text(resultText)
                .font(.largeTitle)
                .bold()
            
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
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#000000"))
                                .fixedSize(horizontal: true, vertical: false) // 防止文字被截斷
                                .rotationEffect(angle)
                                .position(
                                    x: center.x + (wheelSize / 3) * CGFloat(cos(angle.radians)),
                                    y: center.y + (wheelSize / 3) * CGFloat(sin(angle.radians))
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
            .onAppear {
                selectRandomCategories()
            }
        }
        
    }
    
    
    // Randomly choose 20 options
    private func selectRandomCategories() {
        selectedCategories = Array(generatePlayerArray(count: number).shuffled().prefix(20))
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
            resultText = "The winner is \(result)!"
            isSpinning = false
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

#Preview {
    RouletteWheelView(number: 5) { result in
        print("Selected: \(result)")
    }
}

