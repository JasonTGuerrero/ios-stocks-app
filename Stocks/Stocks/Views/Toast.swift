import SwiftUI

extension View {
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
}

struct Toast<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    let presenting: () -> Presenting
    let text: Text

    // Define a fixed height for the toast
    let toastHeight: CGFloat = 75

    var body: some View {
        ZStack(alignment: .bottom) {
            self.presenting()

            VStack {
                self.text
            }
            .frame(width: 300, height: toastHeight) // Set a fixed height
            .background(Color.gray)
            .foregroundColor(Color.white)
            .cornerRadius(toastHeight / 2)
            .transition(.slide)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.isShowing = false
                    }
                }
            }
            .padding()
            .opacity(self.isShowing ? 1 : 0)
            .animation(Animation.easeInOut(duration: 0.5))
        }
    }
}
