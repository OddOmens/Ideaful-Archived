import SwiftUI
import Combine
import Foundation

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
    
    var description: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

class ThemeManager: ObservableObject {
    
    enum ThemeType: String {
        case light, dark, system
    }
    
    @Published var currentTheme: ThemeType {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "theme")
            applyTheme()
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "theme"),
           let theme = ThemeType(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.applyTheme()
            }
            .store(in: &cancellables)
        
        applyTheme()
    }
    
    func applyTheme() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            switch currentTheme {
            case .light:
                windowScene.windows.first?.overrideUserInterfaceStyle = .light
            case .dark:
                windowScene.windows.first?.overrideUserInterfaceStyle = .dark
            case .system:
                windowScene.windows.first?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }

}

struct ThemeSelectionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        List {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Button(action: {
                    themeManager.currentTheme = ThemeManager.ThemeType(rawValue: theme.rawValue) ?? .system
                }) {
                    HStack {
                        Text(theme.description)
                        Spacer()
                        if themeManager.currentTheme.rawValue == theme.rawValue {
                            Image("check")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color.colorPrimary)
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                
                        }
                    }
                }
            }
        }.listStyle(.inset)
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 10) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("arrow-left")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color.colorPrimary)
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            
                    }
                }
            }
        }
    }
}
