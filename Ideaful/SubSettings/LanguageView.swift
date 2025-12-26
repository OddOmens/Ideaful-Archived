import SwiftUI
import Combine
import Foundation

private var associatedKey: UInt8 = 0

// Supported languages for the app
struct SupportedLanguage: Identifiable, Equatable {
    let id: String  // Use language code as a unique ID
    let name: String
    let flag: String  // Flag emoji for the language

    static func ==(lhs: SupportedLanguage, rhs: SupportedLanguage) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.flag == rhs.flag
    }
}

// Define available languages
let languages = [
    SupportedLanguage(id: "en", name: "English", flag: "🇺🇸"),
    SupportedLanguage(id: "fr", name: "French", flag: "🇫🇷"),
    SupportedLanguage(id: "de", name: "German", flag: "🇩🇪"),
    SupportedLanguage(id: "es", name: "Spanish", flag: "🇪🇸"),
    SupportedLanguage(id: "zh-Hans", name: "Chinese (Simplified)", flag: "🇨🇳"),
    SupportedLanguage(id: "ja", name: "Japanese", flag: "🇯🇵"),
    SupportedLanguage(id: "ko", name: "Korean", flag: "🇰🇷"),
    SupportedLanguage(id: "pt", name: "Portuguese", flag: "🇵🇹"),
    SupportedLanguage(id: "hi", name: "Hindi", flag: "🇮🇳")
]


// Manages the app's current language setting
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    @Published var selectedLanguage: SupportedLanguage
    
    private var cancellable: AnyCancellable?
    
    init() {
        let storedLanguageCode = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        self.selectedLanguage = languages.first { $0.id == storedLanguageCode } ?? languages[0]
        Bundle.setLanguage(selectedLanguage.id)
        
        // Observe locale changes
        cancellable = NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    func updateLanguage(to language: SupportedLanguage) {
        selectedLanguage = language
        UserDefaults.standard.set(language.id, forKey: "selectedLanguage")
        Bundle.setLanguage(language.id)
        NotificationCenter.default.post(name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
}



// Extension to Bundle to switch the app's language dynamically
extension Bundle {
    static func setLanguage(_ language: String) {
        object_setClass(Bundle.main, AnyLanguageBundle.self)
        objc_setAssociatedObject(Bundle.main, &associatedKey, Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? ""), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        (objc_getAssociatedObject(self, &associatedKey) as? Bundle)?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}

// SwiftUI view for language selection
struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager

    
    var body: some View {
        VStack {
            HStack {
                Image("flag") // Symbol for About
                    .resizable()
                    .renderingMode(.template)
                    
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .cornerRadius(80)
                Text("Languages outside of English may not be translated fully or correctly.".localized)
                    
                
                Spacer()
            }.padding(.leading,20)
            List(languages, id: \.id) { language in
                Button(action: {
                    languageManager.updateLanguage(to: language)
                }) {
                    HStack {
                        Text(language.flag)
                            
                        Text(language.name)
                            
                        
                        Spacer()
                        
                        // Display a checkmark if this is the selected language
                        if languageManager.selectedLanguage.id == language.id {
                            Image(systemName: "checkmark")
                                
                        }
                    }
                }.listRowBackground(Color.clear).scrollContentBackground(.hidden)
                
            }.scrollDisabled(true)
            .listRowBackground(Color.clear)
            .listRowBackground(Color.clear).scrollContentBackground(.hidden)
            .listStyle(InsetListStyle())
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Select Language".localized)
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

extension String {
    var localized: String {
        NSLocalizedString(self, tableName: nil, bundle: .main, value: "", comment: "")
    }
}
 
