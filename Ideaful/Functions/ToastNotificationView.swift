import SwiftUI
import Combine
import UIKit

class ToastNotificationViewModel: ObservableObject {
    static let shared = ToastNotificationViewModel()
    
    private let toastPresenter = ToastPresenter()
    
    private init() {}
    
    func showNotification(message: String, icon: String, duration: Double = 3.0) {
        toastPresenter.enqueueToast(message: message, icon: icon, duration: duration)
    }
}

class ToastPresenter {
    private var toastWindow: UIWindow?
    private let toastQueue = DispatchQueue(label: "com.example.toastQueue", attributes: .concurrent)
    private var toastQueueArray: [(String, String, Double)] = []
    private var isShowingToast = false
    
    func enqueueToast(message: String, icon: String, duration: Double) {
        toastQueue.async(flags: .barrier) {
            self.toastQueueArray.append((message, icon, duration))
            if !self.isShowingToast {
                self.showNextToast()
            }
        }
    }
    
    private func showNextToast() {
        toastQueue.async(flags: .barrier) {
            if !self.toastQueueArray.isEmpty {
                let (message, icon, duration) = self.toastQueueArray.removeFirst()
                self.show(toast: message, icon: icon, duration: duration)
            }
        }
    }
    
    private func show(toast: String, icon: String, duration: Double) {
        isShowingToast = true
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            self.toastWindow = UIWindow(windowScene: scene)
            self.toastWindow?.backgroundColor = .clear
            
            self.toastWindow?.frame = CGRect(x: 0, y: scene.screen.bounds.height, width: scene.screen.bounds.width, height: 100)
            
            let view = ToastView(message: toast, icon: icon, dismissAction: self.dismissToast)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                .padding(.horizontal, 18)
            
            self.toastWindow?.rootViewController = UIHostingController(rootView: view)
            self.toastWindow?.rootViewController?.view.backgroundColor = .clear
            
            self.toastWindow?.makeKeyAndVisible()
            UIView.animate(withDuration: 0.5, animations: {
                self.toastWindow?.frame = CGRect(x: 0, y: scene.screen.bounds.height - 150, width: scene.screen.bounds.width, height: 100)
            })
            
            // Hide the toast automatically after the specified duration with slide down animation
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.dismissToast()
            }
        }
    }
    
    private func dismissToast() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            UIView.animate(withDuration: 0.5, animations: {
                self.toastWindow?.frame = CGRect(x: 0, y: scene.screen.bounds.height, width: scene.screen.bounds.width, height: 100)
            }) { _ in
                self.toastWindow?.isHidden = true
                self.toastWindow = nil
                self.isShowingToast = false
                self.showNextToast()
            }
        }
    }
}

struct ToastView: View {
    let message: String
    let icon: String
    let dismissAction: () -> Void

    var body: some View {
        HStack {
            Image(icon) // Use icon directly
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(10)
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Button(action: {
                dismissAction()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
            }
        }
        .padding()
    }
}
