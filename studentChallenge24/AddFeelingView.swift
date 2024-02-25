
import SwiftUI
import SwiftData
import AVFoundation

enum WriteStage {
    case breath
    case identify
    case analyzeCause
    mutating func nextStage() {
        switch self {
        case .breath:
            self = .identify
        case .identify:
            self = .analyzeCause
        case .analyzeCause:
            break
        }
    }
    mutating func previousStage() {
        self = .identify
    }
    var questionText: String {
        switch self {
        case .breath:
            "Take a deep breath for a moment..."
        case .identify:
            "How do you feel now?"
        case .analyzeCause:
            "What made you feel that way?"

        }
    }
}
enum SuicideWay: String, CaseIterable {
    case selfharm = "self-harm"
    case posioning
    case firearms

    var imageString: String {
        switch self {
        case .selfharm:
            "selfharm"
        case .posioning:
            "drug"
        case .firearms:
            "gunhead"
        }
    }
    var selectImageString: String {
        switch self {
        case .selfharm:
            "wristblood"
        case .posioning:
            "drug"
        case .firearms:
            "gunblood"
        }
    }
    var description: String {
        switch self {
        case .selfharm:
            "Excessive bleeding can lead to shock, starting with mild symptoms even at 0.75 liters lost and progressing to a critical state if over 1.5 liters are lost. As blood loss increases, blood pressure rises, heart rate accelerates, and tissues may not receive sufficient blood, leading to hemorrhagic shock."
        case .posioning:
            "Especially pesticides like Gramoxone are referred to as the 'devil's potion', causing a sensation of burning pain in the mouth within minutes to hours after ingestion. Moreover, ulcers can develop on the lips, tongue, and throat within 48 hours. Even worse, esophageal ulcers can lead to perforation, and irreversible bodily damage such as pulmonary fibrosis can occur. It's crucial to note that even amidst excruciating pain, mental faculties remain largely intact."
        case .firearms:
            "Your body will have two holes: one where the bullet enters and one where it exits. The wall around the exit wound will be mushy with brain matter due to the impact, and the skull will be left empty."
        }
    }
}
enum Feeling: String, CaseIterable {
    case normal
    case good
    case sad
    case angry
    case suicidal = "suicidal\nthoughts"
    case selfloathing = "self\nloathing"
    var imageString: String {
        switch self {
        case .normal:
            "normal"
        case .good:
            "sun"
        case .sad:
            "sadcloud"
        case .angry:
            "angrycloud"
        case .suicidal:
            "thunder"
        case .selfloathing:
            "selfhate"
        }
    }
    var colorString: Color {
        switch self {
        case .normal:
            Color.backgroundMint
        case .good:
            Color.backgroundOrange
        case .sad:
            Color.backgroundSad
        case .angry:
            Color.backgroundAngry
        case .suicidal:
            Color.backgroundYellow
        case .selfloathing:
            Color.lightdarkblue
        }
    }
    init?(stringValue: String) {
        for feeling in Feeling.allCases {
            if stringValue == feeling.rawValue {
                self = feeling
                return
            }
        }
        return nil
    }
}
struct AddFeelingView: View {
    @Environment(\.modelContext) var context
    @Binding var isOpen: Bool
    @State private var animate = false
    @State private var isChooseSelfLoss: Bool = false
    let colors: [Color] = [.black.opacity(0.2), .purple.opacity(0.2),
                           .violet.opacity(0.2),
                           .white.opacity(0.2)]
    let colums = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @State private var stage: WriteStage = .breath
    @State private var countdown = 3
    @State private var currentFeeling: Feeling = .normal
    @State private var causetext: String = ""
    @State private var suicideway: SuicideWay?
    @State private var isChooseSuicide: Bool = false
    @FocusState private var causeFocused: Bool
    @State private var player: AVAudioPlayer?
    var body: some View {
        ZStack {
            backgroundAnimation
            contentView
            if isChooseSuicide {suicideWayChoose
                .padding(.horizontal, 80)
                .padding(.vertical,160)}
            if isChooseSelfLoss {
                selflossChooseView
                    .padding(.horizontal, 80)
                    .padding(.vertical,160)
            }
        }.onTapGesture {
            causeFocused = false
        }
        .onAppear {
            guard let path = Bundle.main.path(forResource: "medtation", ofType: "mp3") else {return}
            let url = URL(fileURLWithPath: path)
            player = try? AVAudioPlayer(contentsOf: url)
            player?.play()
            startBreathCount()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .edgesIgnoringSafeArea(.all)
    }
}
extension AddFeelingView {
    var backgroundAnimation: some View {
        ForEach(0..<4) { index in
            Circle()
                .fill(self.colors[index])
                .frame(width: 500, height: 500)
                .scaleEffect(self.animate ? 1 : 0.5)
                .opacity(self.animate ? 0.0 : 1.0)
                .animation(Animation.easeInOut(duration: 5).repeatForever(autoreverses: true).delay(Double(index) / 2), value: animate)
        }
        .onAppear {
            self.animate = true
        }
    }
    var contentView: some View {
        VStack {
            Text(stage.questionText)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom,40)
            switch stage {
            case .breath:
                Text("\(countdown)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .transition(.scale)
            case .identify:
                LazyVGrid(columns: colums ,spacing: 10) {
                    ForEach(Feeling.allCases,id: \.self) { feeling in
                        Button(action: {
                            currentFeeling = feeling
                            if feeling == .suicidal {
                                isChooseSuicide.toggle()
                            } else if feeling == .selfloathing {
                                isChooseSelfLoss.toggle()
                            }
                            stage.nextStage()
                        }, label: {
                            Text(feeling.rawValue)
                                .foregroundStyle(.violet)
                                .font(.headline)
                                .background {
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(width: 80,height: 40)
                                        .foregroundStyle(Color.lightGray)
                                }
                        })
                        .padding(.vertical,5)
                    }
                }
            case .analyzeCause:
                VStack {
                    ZStack{
                        TextEditor(text: $causetext )
                            .focused($causeFocused)
                            .clipShape(.rect(cornerRadius: 8))
                            .font(.body)
                        if causetext.isEmpty {
                            VStack {
                                Text("Just write down why you feel this way will help you!")
                                    .font(.body)
                                    .foregroundStyle(Color.primary.opacity(0.5))
                                    .lineSpacing(10)
                                    .padding(.top,8)
                                Spacer()
                            }.onTapGesture {
                                causeFocused = true
                            }
                        }
                    }.frame(height: 160)
                        .padding(.bottom,8)
                    HStack {
                        Button(action: {stage.previousStage()}, label: {
                            Image(systemName: "arrow.backward")
                                .foregroundStyle(.white)
                                .font(.title2)
                        })
                        Spacer()
                        Button(action: {

                            let data = Feelinginfo(date:  Date().formatted(), feeling: currentFeeling.rawValue, reason: causetext)
                            context.insert(data)
                            isOpen.toggle()
                        }, label: {
                            Image(systemName: "arrow.forward")
                                .foregroundStyle(.white)
                                .font(.title2)
                        })
                    }
                }.padding(.bottom, causeFocused ? 100: 0)
            }
        }.padding(.horizontal,100)
    }
    func startBreathCount() {
        if stage == .breath {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {timer in
                if self.countdown > 1 {
                    self.countdown -= 1
                } else {
                    timer.invalidate()
                    self.stage.nextStage()
                    self.countdown = 3
                }
            }
        }
    }

    @ViewBuilder
    var suicideWayChoose: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.lightGray.opacity(0.2),lineWidth: 1))
                .shadow(color: Color.lightGray.opacity(0.4), radius: 4)
            if let suicideway = suicideway {
                VStack(spacing: 8) {
                    Text("You know that?")
                        .font(.system(size: 28,weight: .semibold))
                        .foregroundStyle(.red)
                    Image(suicideway.selectImageString)
                        .resizable()
                        .frame(width: 72,height: 72)
                    Text(suicideway.description)
                        .foregroundStyle(.red)
                        .font(.system(size: 15))
                    Spacer()
                    Button(action: {isChooseSuicide.toggle()}, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 40,height: 40)
                            .foregroundStyle(Color.red)
                    })
                }.padding(.vertical, 32)
            }else {
                VStack {
                    Text("How do you kill yourself?")
                        .font(.system(size: 24,weight: .semibold))
                        .foregroundStyle(.red)
                    HStack {
                        ForEach(SuicideWay.allCases, id: \.self){ way in
                            Button(action: {
                                suicideway = way
                            }, label: {
                                VStack{
                                    Image(way.imageString)
                                        .resizable().frame(width: 64,height: 64)
                                    Text(way.rawValue)
                                        .foregroundStyle(.red)
                                }
                            })
                        }
                    }
                    Text("Before choosing, wrap a rubber band around your wrist and pull it down the hardest. Suicide multiplies the pain you're feeling, not just for you, but for your family, friends, and loved ones too")
                        .foregroundStyle(.red)
                        .font(.system(size: 14,weight: .semibold))
                        .padding()

                }
            }
        }
    }

    var selflossChooseView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.lightGray.opacity(0.2),lineWidth: 1))
                .shadow(color: Color.lightGray.opacity(0.4), radius: 4)
            VStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 32,height: 32)
                    .foregroundStyle(.red)
                Text("It is a difficult feeling for you to loathe yourself. But we clearly know that you are a strong and precious person. You are a unique value in the world, and no one is exactly the same as you. Do not allow feelings of self-loathing to take over you. We are not all perfect. We are human beings who grow and learn by making mistakes and failing, and that is the process by which we grow.")
                    .font(.system(size: 16, weight: .medium))
                Text("You deserve love and understanding\nPlease know how precious and outstanding human you are!")
                    .font(.system(size: 22,weight: .heavy))
                    .foregroundStyle(Color.violet)
                Button(action: {isChooseSelfLoss.toggle()}, label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 40,height: 40)
                        .foregroundStyle(Color.green)
                })
            }
        }
    }
}
