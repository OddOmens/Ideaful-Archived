import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var showDeviceReminders: Bool = UserDefaults.standard.bool(forKey: "showDeviceReminders")
    @State private var showDeviceDueDate: Bool = UserDefaults.standard.bool(forKey: "showDeviceDueDate")
    @State private var showUserAchievements: Bool = UserDefaults.standard.bool(forKey: "showUserAchievements")
    @State private var showIconAchievements: Bool = UserDefaults.standard.bool(forKey: "showIconAchievements")

    @EnvironmentObject var themeManager: ThemeManager

    init() {
        // Set default values to true if not already set
        UserDefaults.standard.register(defaults: [
            "showDeviceReminders": true,
            "showDeviceDueDate": true,
            "showUserAchievements": true,
            "showIconAchievements": true
        ])
    }

    var body: some View {
        List {
            Section(header: Text("Device Notifications".localized)) {
                Toggle(isOn: $showDeviceReminders) {
                    NotificationRowView(imageName: "mobile-alt-1-notification", title: "Task Reminders".localized, description: "Device notifications will show when a task reminder is set".localized)
                }
                .onChange(of: showDeviceReminders) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "showDeviceReminders")
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $showDeviceDueDate) {
                    NotificationRowView(imageName: "mobile-alt-1-notification", title: "Task Due Dates".localized, description: "Device notifications will show when a task is due".localized)
                }
                .onChange(of: showDeviceDueDate) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "showDeviceDueDate")
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
            }
            
            /*Section(header: Text("In-App Notifications".localized)) {
                Toggle(isOn: $showUserAchievements) {
                    NotificationRowView(imageName: "message-circle-notification", title: "Unlocking Achievements".localized, description: "In-app notifications will show when an achievement is earned".localized)
                }
                .onChange(of: showUserAchievements) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "showUserAchievements")
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
            }*/
        }
        .listStyle(.inset)
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .navigationTitle("Notifications".localized)
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

struct NotificationRowView: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    
                VStack(alignment: .leading) {
                    Text(title)
                        .bold()
                        .font(.system(size: 15))
                    Text(description)
                        .font(.caption)
                }
            }
        }
    }
}
