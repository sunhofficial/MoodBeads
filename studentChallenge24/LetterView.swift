
import SwiftUI
enum LetterType {
    case receive
    case send
}
struct LetterView: View {
    var letterType: LetterType
    @Binding var show: Bool
    @AppStorage("sendText") var sendText: String = ""
    @AppStorage("lastAccessData") var lastAccessData: String?
    @State private var diaryText: String = ""
    var body: some View {
        VStack {
            HStack {
                Text("From: " ) + Text(letterType == .receive ? "My Yesterday" : "Today's Me")
                Spacer()
            }.font(.system(size: 14,weight: .semibold))
                .padding(.top, 8)
                .padding(.leading, 8)
            if letterType == .send {
                if sendText == "" {
                    TextField("Write your diary for tomorrow", text:
                                Binding(get: {
                        diaryText
                    }, set: { (newvalue, _) in
                        if let _ = newvalue.lastIndex(of: "\n") {
                            lastAccessData = Date().nowtimeFormatted()
                            sendText = diaryText
                            show.toggle()
                        } else {
                            diaryText = newvalue
                        }
                    }), axis: .vertical)
                    .lineLimit(3,reservesSpace: true)
                    .padding()
                    .submitLabel(.send)
                }
                else {
                    VStack {
                        Text(sendText)
                        Button(action: {
                            sendText = ""
                        }, label: {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 24,height: 24)
                                .foregroundStyle(Color.green)
                        })
                    }
                }
            } else {
                Text(sendText)
            }
            HStack {
                Spacer()
                Text("To: ") + Text(letterType == .receive ? "Today's Me" : "Tomorrow's me")
            }.font(.system(size: 14,weight: .semibold))
                .padding(.bottom, 8)
                .padding(.trailing, 8)
        }.background(Color.letterBackground)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 32)
            .background(
                Color.primary.opacity(0.35)
                    .onTapGesture {
                        withAnimation {
                            show.toggle()
                        }
                    }
            )
    }
}
