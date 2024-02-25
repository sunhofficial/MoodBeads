import SwiftUI
import SwiftData

struct DiaryView: View {
    @Query var feelingDatas: [Feelinginfo]
    @Environment(\.modelContext) var context
    var motionManager: MotionManager
    var info: DiaryModel
    @Binding var show: Bool
    @Binding var isErased: Bool
    var spriteScene: SpriteScene
    @State private var isDetect: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Spacer()
                Text(info.date)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.white)
                Spacer()
            }.padding(.top, 16)
            ZStack (alignment: .topLeading){
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.clear)
                    .background(BlurView().clipShape(.rect(cornerRadius: 20)))
                Text(info.reason)
                    .font(.system(size: 14,weight: .regular))
                    .padding()
            }
            .padding()
            feelingToTrashView
                .padding(.bottom, 16)
                .padding(.horizontal, 24)
        }.background(info.feeling.colorString)
            .clipShape(.rect(cornerRadius: 20))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 32)
            .padding(.vertical, 200)
            .background(
                Color.primary.opacity(0.35)
                    .onTapGesture {
                        withAnimation {
                            show.toggle()
                        }
                    }
            )
            .onAppear {
                motionManager.deleteDetect {
                    isDetect.toggle()
                }
            }
            .alert(isPresented: $isDetect) {
                Alert(
                    title: Text("Delete"),
                    message: Text("Do you want to erase this feeling?"),
                    primaryButton: .destructive(Text("Erase")) {
                        deleteDiary()
                    },
                    secondaryButton: .cancel() {
                        motionManager.deleteDetect {
                            isDetect.toggle()
                        }
                    }
                )
            }

    }
}
extension DiaryView {
    var feelingToTrashView: some View {
        VStack(spacing: 0) {
            HStack {
                Image(info.feeling.imageString)
                    .resizable()
                    .frame(width: 64,height: 64)
                Image("arrow")
                    .resizable()
                    .frame(maxWidth: 200)
                    .frame(height: 24)
                    .padding(.leading,16)
                    .padding(.trailing,24)
                Button(action: {
                    isDetect.toggle()
                }, label: {
                    Image(systemName: "arrow.up.trash")
                        .resizable()
                        .frame(width: 32, height: 32)
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
            Text("Shake It!")
                .foregroundStyle(Color.white)
                .font(.system(size: 24, weight: .bold))
            Text("if you want to erase this Feeling!!")
                .foregroundStyle(Color.white)
                .font(.system(size: 16, weight: .bold))


        }
    }
    func deleteDiary() {
        if let eraseData = feelingDatas.firstIndex(where:{ $0.date == info.date}) {
            context.delete(feelingDatas[eraseData])
            motionManager.coreMotionmanger.startAccelerometerUpdates()
            show.toggle()
            spriteScene.replaceNode(name: info.date)

        }
    }
}
struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}
