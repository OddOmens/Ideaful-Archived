import SwiftUI
import CoreData
import CloudKit

struct SettingsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var themeManager: ThemeManager

    @EnvironmentObject var userSettings: UserSettings
    
    @FetchRequest(entity: Idea.entity(), sortDescriptors: []) var ideas: FetchedResults<Idea>
    
    @State private var showingDeleteAlert = false
    
    @Environment(\.openURL) var openURL
    
    @AppStorage("isIconAchievementsButtonEnabled") var isIconAchievementsButtonEnabled: Bool = false
    @AppStorage("isTasksButtonEnabled") var isTasksButtonEnabled: Bool = true
    @AppStorage("isAllTaskCountButtonEnabled") var isAllTaskCountButtonEnabled: Bool = true
    @AppStorage("isTaskCountButtonEnabled") var isTaskCountButtonEnabled: Bool = true
    @AppStorage("isShortDescEnabled") var isShortDescEnabled: Bool = true
    @AppStorage("isCancelledIdeaButtonEnabled") var isCancelledIdeaButtonEnabled: Bool = true
    @AppStorage("isCompletedIdeaButtonEnabled") var isCompletedIdeaButtonEnabled: Bool = true
    @AppStorage("isArchivedIdeaButtonEnabled") var isArchivedIdeaButtonEnabled: Bool = false
    
    var body: some View {
        List {

                
                Section(header: Text("Customization".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()) {
                    NavigationLink(destination: IconPickerView()) {
                        SettingRowView(imageName: "glasses", title: "App Icon".localized)
                    }
                    NavigationLink(destination: ThemeSelectionView()) {
                        SettingRowView(imageName: "palette", title: "Theme".localized)
                    }
                    NavigationLink(destination: StatusesView()) {
                        SettingRowView(imageName: "notes", title: "Statuses".localized)
                    }
                    NavigationLink(destination: CustomizeView()) {
                        SettingRowView(imageName: "grid", title: "Features".localized)
                    }
                    NavigationLink(destination: NotificationsView()) {
                        SettingRowView(imageName: "bell-alt", title: "Notifications".localized)
                    }
                }
                
                Section(header: Text("Language".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()){
                    NavigationLink(destination: LanguageSelectionView()) {
                        SettingRowView(imageName: "flag", title: "Language".localized)
                    }
                }
                
                Section(header: Text("Data Management".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()){
                    NavigationLink(destination: ExportOptionsView().environment(\.managedObjectContext, viewContext)) {
                        SettingRowView(imageName: "file-arrow-down-alt", title: "Export Ideas".localized)
                    }
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        SettingRowView(imageName: "file-shredder", title: "Mass Delete Ideas".localized)
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Are you sure you want to delete all of your ideas?".localized),
                            primaryButton: .destructive(Text("Delete".localized)) {
                                deleteAllIdeas()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                
                Section(header: Text("Help".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()){
                    Button(action: { openURL(URL(string: "https://docs.oddomens.com")!) }) {
                        SettingRowView(imageName: "message-square-info", title: "Documentation".localized)
                    }
                    Button(action: { sendSupportEmail() }) {
                        SettingRowView(imageName: "mail", title: "Email Support".localized)
                    }
                    Button(action: { sendReportIssueEmail() }) {
                        SettingRowView(imageName: "message-square-info", title: "Report an Issue".localized)
                    }
                    Button(action: { sendRequestFeatureEmail() }) {
                        SettingRowView(imageName: "message-square-question", title: "Request a Feature".localized)
                    }
                }
                
                Section(header: Text("About Ideaful".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()){
                    Button(action: { openURL(URL(string: "https://apps.apple.com/us/app/ideaful/id6463294844")!) }) {
                        SettingRowView(imageName: "star", title: "Rate Ideaful".localized)
                    }
                    NavigationLink(destination: VersionView()) {
                        HStack {
                            SettingRowView(imageName: "certificate-check", title: "Version")
                            Text("2025.12.1")
                                .font(.footnote)
                                
                        }
                    }
                }
                
                Section(header: Text("Privacy and Terms".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()){
                    Button(action: { openURL(URL(string: "https://oddomens.com/privacy")!) }) {
                        SettingRowView(imageName: "memo-check", title: "Privacy Policy")
                    }
                    Button(action: { openURL(URL(string: "https://oddomens.com/terms")!) }) {
                        SettingRowView(imageName: "memo-check", title: "Terms of Service")
                    }
                }
            }
            .listRowBackground(Color.clear)
        
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings".localized)
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
    
    private func sendSupportEmail() {
        let emailSubject = "Ideaful App Support"
        let emailBody = "Hello, I need help with..."
        let emailAddress = "support@oddomens.com"

        let encodedSubject = emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let mailtoURL = URL(string: "mailto:\(emailAddress)?subject=\(encodedSubject)&body=\(encodedBody)") {
            openURL(mailtoURL)
        }
    }

    private func sendReportIssueEmail() {
        let emailSubject = "Ideaful - Report an Issue"
        let emailBody = "Hello, I would like to report the following issue:\n\n"
        let emailAddress = "support@oddomens.com"

        let encodedSubject = emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let mailtoURL = URL(string: "mailto:\(emailAddress)?subject=\(encodedSubject)&body=\(encodedBody)") {
            openURL(mailtoURL)
        }
    }

    private func sendRequestFeatureEmail() {
        let emailSubject = "Ideaful - Request a Feature"
        let emailBody = "Hello, I would like to request the following feature:\n\n"
        let emailAddress = "support@oddomens.com"

        let encodedSubject = emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let mailtoURL = URL(string: "mailto:\(emailAddress)?subject=\(encodedSubject)&body=\(encodedBody)") {
            openURL(mailtoURL)
        }
    }
    
    private func deleteAllIdeas() {
        let fetchRequest: NSFetchRequest<Idea> = Idea.fetchRequest()

        do {
            let ideasToDelete = try managedObjectContext.fetch(fetchRequest)
            for idea in ideasToDelete {
                managedObjectContext.delete(idea)
            }
            try managedObjectContext.save()
        } catch {
            print("Error deleting all ideas: \(error.localizedDescription)")
        }
    }
}

struct SettingRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let imageName: String
    let title: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(6)
            Text(title)
        }
    }
}
