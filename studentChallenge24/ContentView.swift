import SwiftUI
import SwiftData
import SpriteKit

struct ContentView: View {
    @Environment(\.modelContext) var context
    @Query var feelingDatas: [Feelinginfo]
    var motionManger = MotionManager()
    @State private var showingSheet = false
    @State private var scene: SKScene? = nil
    @State private var nodeTap: Bool = false
    @State private var touchInfo: DiaryModel?
    @State private var isErased: Bool = false
    @State private var isLetterTouched: Bool = false
    @AppStorage("lastAccessData") var lastAccessData: String?
    @State private var isSend: Bool = false
    var isFirstAccessToday: Bool {
        return lastAccessData !=  Date().nowtimeFormatted()
    }
    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene).ignoresSafeArea()
            }
            if nodeTap {
                if let scene = scene {
                    DiaryView( motionManager: motionManger,info: touchInfo!,show: $nodeTap, isErased: $isErased, spriteScene: scene as! SpriteScene)
                        .ignoresSafeArea()
                }
            }
            if isFirstAccessToday && isSend {
                LetterView(letterType: .send, show: $isSend).ignoresSafeArea()
            }
            if isLetterTouched {
                LetterView(letterType: .receive, show: $isLetterTouched).ignoresSafeArea()
            }
            VStack {
                HStack{
                    Spacer()
                    diaryButton
                }.padding()
                Spacer()
            }
        }.onAppear {
            scene = makeScene()
            isSend = isFirstAccessToday ? true : false
            NotificationCenter.default.addObserver(forName: NSNotification.Name("TreeTapped"), object: nil, queue: .main) { _ in
                showingSheet.toggle()
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("FeelingTapped"), object: nil, queue: .main) { node in
                if let nodeObject = node.object as? SKSpriteNode {
                    if let name = nodeObject.name {
                        let touchNode = feelingDatas.filter {$0.date == name}
                        if let feeling = Feeling(stringValue: touchNode[0].feeling) {
                            touchInfo = DiaryModel(feeling: feeling, date: touchNode[0].date, reason: touchNode[0].reason)
                        } else {}
                    }
                }
                nodeTap.toggle()
            }
        }
        .onDisappear {
            if isFirstAccessToday {
                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                lastAccessData = dateFormatter.string(from: today)
            }
        }
        .onChange(of: showingSheet) { oldValue, newValue in
            if newValue == false {
                scene = makeScene()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.scene = nil
                }
            }
        }
        .fullScreenCover(isPresented: $showingSheet) {
            AddFeelingView(isOpen: $showingSheet)
        }
        
    }
}
extension ContentView {
    var diaryButton: some View {
        Button(action: {isLetterTouched.toggle()}, label: {
            Image(systemName: "envelope.badge.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.white)
                .background {
                    Circle()
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.lightdarkblue)
                }
                .background {
                    Circle()
                        .frame(width: 48, height: 48)
                        .foregroundStyle(Color.lightdarkblue)
                        .shadow(color: .white, radius: 4,x: 4,y:4)
                        .blur(radius: 4)
                }
        })
    }
    func makeScene() -> SKScene {
        let scene = SpriteScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        scene.motionManger = motionManger
        scene.scaleMode = .resizeFill
        scene.feelingDatas = feelingDatas
        return scene
    }
}
