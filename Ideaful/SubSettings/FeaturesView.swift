import SwiftUI
import CoreData
import Combine

extension UserDefaults {
    /// Custom method to provide a default value when fetching a boolean value from UserDefaults.
    func bool(forKey defaultName: String, defaultBool: Bool) -> Bool {
        if object(forKey: defaultName) == nil {
            return defaultBool
        }
        return bool(forKey: defaultName)
    }
}

class UserSettings: ObservableObject {
    
    //MARK: - Tasks
    @Published var showTasks: Bool = UserDefaults.standard.bool(forKey: "showTasks", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showTasks, forKey: "showTasks")
        }
    }
    
    @Published var showTaskCount: Bool = UserDefaults.standard.bool(forKey: "showTaskCount", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showTaskCount, forKey: "showTaskCount")
        }
    }
    
    @Published var showAllTaskCount: Bool = UserDefaults.standard.bool(forKey: "showAllTaskCount", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showAllTaskCount, forKey: "showAllTaskCount")
        }
    }
    
    @Published var showTaskOverview: Bool = UserDefaults.standard.bool(forKey: "showTaskOverview", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showTaskOverview, forKey: "showTaskOverview")
        }
    }
    
    @Published var showTaskPriorities: Bool = UserDefaults.standard.bool(forKey: "showTaskPriorities", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showTaskPriorities, forKey: "showTaskPriorities")
        }
    }
    
    
    //MARK: - Ideas
    @Published var showCancelledIdeas: Bool = UserDefaults.standard.bool(forKey: "showCancelledIdeas", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showCancelledIdeas, forKey: "showCancelledIdeas")
        }
    }
    
    @Published var showCompletedIdeas: Bool = UserDefaults.standard.bool(forKey: "showCompletedIdeas", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showCompletedIdeas, forKey: "showCompletedIdeas")
        }
    }
    
    @Published var showArchivedIdeas: Bool = UserDefaults.standard.bool(forKey: "showArchivedIdeas", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showArchivedIdeas, forKey: "showArchivedIdeas")
        }
    }
    
    @Published var showShortDesc: Bool = UserDefaults.standard.bool(forKey: "showShortDesc", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showShortDesc, forKey: "showShortDesc")
        }
    }

    @Published var showCompactView: Bool = UserDefaults.standard.bool(forKey: "showCompactView", defaultBool: false) {
        didSet {
            UserDefaults.standard.set(showCompactView, forKey: "showCompactView")
        }
    }
    
    //MARK: - Notifications
    @Published var showDeviceReminders: Bool = UserDefaults.standard.bool(forKey: "showDeviceReminders", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showDeviceReminders, forKey: "showDeviceReminders")
        }
    }
    
    @Published var showDeviceDueDate: Bool = UserDefaults.standard.bool(forKey: "showDeviceDueDate", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showDeviceDueDate, forKey: "showDeviceDueDate")
        }
    }
    
    @Published var showUserAchievements: Bool = UserDefaults.standard.bool(forKey: "showUserAchievements", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showUserAchievements, forKey: "showUserAchievements")
        }
    }
    
    //MARK: - Confirmations
    @Published var showDeleteConfirmation: Bool = UserDefaults.standard.bool(forKey: "showDeleteConfirmation", defaultBool: true) {
        didSet {
            UserDefaults.standard.set(showDeleteConfirmation, forKey: "showDeleteConfirmation")
        }
    }
}

struct CustomizeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSettings: UserSettings

    var body: some View {
        List {
            Section(header: Text("Tasks".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()) {
                Toggle(isOn: $userSettings.showTasks) {
                    FeatureRowView(imageName: "list", title: "Enable Tasks".localized, description: "Task feature and UI will be shown".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $userSettings.showTaskCount) {
                    FeatureRowView(imageName: "list", title: "Show Task Count (Ideas)".localized, description: "Task count on idea view".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $userSettings.showAllTaskCount) {
                    FeatureRowView(imageName: "list", title: "Show Task Count (Dashboard)".localized, description: "Task count on dashboard for all tasks".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $userSettings.showTaskOverview) {
                    FeatureRowView(imageName: "calendar", title: "Show Task Overview".localized, description: "Display task overview in TasksView".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $userSettings.showTaskPriorities) {
                    FeatureRowView(imageName: "flag", title: "Show Task Priorities".localized, description: "Display task priorities in TasksView".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Notes".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()) {
                Toggle(isOn: $userSettings.showShortDesc) {
                    FeatureRowView(imageName: "notes", title: "Show Dashboard Description".localized, description: "Dashboard description will be shown".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)

                Toggle(isOn: $userSettings.showCompactView) {
                    FeatureRowView(imageName: "grid", title: "Compact View".localized, description: "Show ideas in a denser layout".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Ideas".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()) {
                Toggle(isOn: $userSettings.showCancelledIdeas) {
                    FeatureRowView(imageName: "xmark", title: "Show Cancelled Ideas".localized, description: "Cancelled ideas will be shown".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $userSettings.showCompletedIdeas) {
                    FeatureRowView(imageName: "check", title: "Show Completed Ideas".localized, description: "Completed ideas will be shown".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $userSettings.showArchivedIdeas) {
                    FeatureRowView(imageName: "box-archive", title: "Show Archived Ideas".localized, description: "Archived ideas will be shown".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Notifications".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()) {
                Toggle(isOn: $userSettings.showDeviceReminders) {
                    FeatureRowView(imageName: "bell-alt", title: "Show Device Reminders".localized, description: "Enable reminders on your device".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                Toggle(isOn: $userSettings.showDeviceDueDate) {
                    FeatureRowView(imageName: "calendar-check", title: "Show Device Due Dates".localized, description: "Enable due date notifications on your device".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
                
                /*Toggle(isOn: $userSettings.showUserAchievements) {
                    FeatureRowView(imageName: "trophy", title: "Show User Achievements".localized, description: "Display user achievements and progress".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)*/
            }
            
            Section(header: Text("Confirmations".localized).padding(.horizontal, 10).padding(.vertical, 5).glassEffect()) {
                Toggle(isOn: $userSettings.showDeleteConfirmation) {
                    FeatureRowView(imageName: "trash", title: "Show Delete Confirmation".localized, description: "Prompt before deleting ideas".localized)
                }
                .tint(Color.colorGreen)
                .padding(.vertical, 4)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .navigationTitle("Features".localized)
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

struct FeatureRowView: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(6)
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
