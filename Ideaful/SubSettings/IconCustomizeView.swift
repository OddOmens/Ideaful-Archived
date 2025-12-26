import SwiftUI
import CoreData
import Combine

class IconManager: ObservableObject {
    @Published var icons: [AppIcon] = [
        AppIcon(nameKey: "AppIcon_Default_Name", descriptionKey: "AppIcon_Default_Description", imageName: "AppIcon"),
        AppIcon(nameKey: "AppIcon_Morning_Name", descriptionKey: "AppIcon_Morning_Description", imageName: "AppIconMorning"),
        AppIcon(nameKey: "AppIcon_Midnight_Name", descriptionKey: "AppIcon_Midnight_Description", imageName: "AppIconMidnight"),
        AppIcon(nameKey: "AppIcon_Winter_Name", descriptionKey: "AppIcon_Winter_Description", imageName: "AppIconWinter"),
        AppIcon(nameKey: "AppIcon_Charcoal_Name", descriptionKey: "AppIcon_Charcoal_Description", imageName: "AppIconCharcoal"),
        AppIcon(nameKey: "AppIcon_Norse_Name", descriptionKey: "AppIcon_Norse_Description", imageName: "AppIconNorse"),
        AppIcon(nameKey: "AppIcon_Seaweed_Name", descriptionKey: "AppIcon_Seaweed_Description", imageName: "AppIconSeaweed"),
        AppIcon(nameKey: "AppIcon_Mint_Name", descriptionKey: "AppIcon_Mint_Description", imageName: "AppIconMint"),
        AppIcon(nameKey: "AppIcon_CherryBlossom_Name", descriptionKey: "AppIcon_CherryBlossom_Description", imageName: "AppIconCherryBlossom"),
        AppIcon(nameKey: "AppIcon_Blueberry_Name", descriptionKey: "AppIcon_Blueberry_Description", imageName: "AppIconBlueberry"),
        AppIcon(nameKey: "AppIcon_Default3D_Name", descriptionKey: "AppIcon_Default3D_Description", imageName: "AppIconDefault3D"),
        AppIcon(nameKey: "AppIcon_Yarn_Name", descriptionKey: "AppIcon_Yarn_Description", imageName: "AppIconYarn"),
        AppIcon(nameKey: "AppIcon_TheMoon_Name", descriptionKey: "AppIcon_TheMoon_Description", imageName: "AppIconTheMoon"),
        AppIcon(nameKey: "AppIcon_Ominous_Name", descriptionKey: "AppIcon_Ominous_Description", imageName: "AppIconOminous"),
        AppIcon(nameKey: "AppIcon_Pencil_Name", descriptionKey: "AppIcon_Pencil_Description", imageName: "AppIconPencil"),
        AppIcon(nameKey: "AppIcon_Chromatic_Name", descriptionKey: "AppIcon_Chromatic_Description", imageName: "AppIconChromatic"),
        AppIcon(nameKey: "AppIcon_Bright_Name", descriptionKey: "AppIcon_Bright_Description", imageName: "AppIconBright"),
        AppIcon(nameKey: "AppIcon_Bubblegum_Name", descriptionKey: "AppIcon_Bubblegum_Description", imageName: "AppIconBubblegum"),
        AppIcon(nameKey: "AppIcon_GlowStick_Name", descriptionKey: "AppIcon_GlowStick_Description", imageName: "AppIconGlowStick"),
        AppIcon(nameKey: "AppIcon_DarkGradient_Name", descriptionKey: "AppIcon_DarkGradient_Description", imageName: "AppIconDarkGradient"),
        AppIcon(nameKey: "AppIcon_Debug_Name", descriptionKey: "AppIcon_Debug_Description", imageName: "AppIconDebug")
    ]

    private var viewContext: NSManagedObjectContext
    private var userSettings: UserSettings

    init(viewContext: NSManagedObjectContext, userSettings: UserSettings) {
        self.viewContext = viewContext
        self.userSettings = userSettings
    }
}

struct AppIcon: Identifiable, Equatable {
    let id = UUID()
    let nameKey: String
    let descriptionKey: String
    let imageName: String
    
    var name: String {
        NSLocalizedString(nameKey, comment: "")
    }
    
    var description: String {
        NSLocalizedString(descriptionKey, comment: "")
    }

    static func == (lhs: AppIcon, rhs: AppIcon) -> Bool {
        lhs.id == rhs.id &&
        lhs.nameKey == rhs.nameKey &&
        lhs.descriptionKey == rhs.descriptionKey &&
        lhs.imageName == rhs.imageName
    }
}

struct IconView: View {
    let icon: AppIcon
    let isSelected: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image("Preview" + icon.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .cornerRadius(15)
            VStack(alignment: .leading) {
                Text(icon.name)
                    .font(.headline)
                    .foregroundColor(Color.colorPrimary)
                    .bold()
                
                Text(icon.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color.colorPrimary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.colorGreen)
            }
        }
    }
}

struct IconPickerView: View {
    @State private var selectedIcon: AppIcon?
    @State private var isIconChangeSuccessful = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var iconManager: IconManager
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Section(header: sectionHeader(title: "App Icons", count: iconManager.icons.count)) {
                        ForEach(iconManager.icons) { icon in
                            Button(action: {
                                selectedIcon = icon
                                saveSelectedIcon(icon)
                                
                                setAppIcon(to: icon.imageName == "AppIcon" ? nil : icon.imageName) { success in
                                    if success {
                                        isIconChangeSuccessful = true
                                    } else {
                                        isIconChangeSuccessful = false
                                        selectedIcon = nil
                                    }
                                }
                            }) {
                                IconView(icon: icon, isSelected: selectedIcon == icon && isIconChangeSuccessful)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.bottom)
                }
                .onAppear {
                    loadSelectedIcon()
                }
                Spacer()
            }
            .listRowBackground(Color.clear)
            .scrollContentBackground(.hidden)
            .padding()
        }
        .navigationTitle("App Icon".localized)
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
    
    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text("\(title) (\(count))")
                .font(.system(size: 14))
                .bold()
            Spacer()
        }
    }

    private func saveSelectedIcon(_ icon: AppIcon) {
        UserDefaults.standard.setValue(icon.imageName, forKey: "selectedIconName")
    }
    
    private func loadSelectedIcon() {
        if let savedIconName = UserDefaults.standard.string(forKey: "selectedIconName"),
           let savedIcon = iconManager.icons.first(where: { $0.imageName == savedIconName }) {
            selectedIcon = savedIcon
            isIconChangeSuccessful = true
        }
    }
}

func setAppIcon(to iconName: String?, completion: @escaping (Bool) -> Void) {
    guard UIApplication.shared.supportsAlternateIcons else {
        completion(false)
        return
    }
    
    UIApplication.shared.setAlternateIconName(iconName) { error in
        if let error = error {
            print("Error setting alternate icon: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Successfully changed app icon to: \(iconName ?? "default")")
            completion(true)
        }
    }
}
