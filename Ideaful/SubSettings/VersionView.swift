import SwiftUI

struct VersionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager //Theme Management System
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Section {
                    Text("Release 2025.12.1")
                        .font(.headline)
                    Text("Release Date: December 2025")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("""
                        • Updated the "Request a Feature" link
                        • Updated the "Report a Issue" link
                        • Updated the "Documentation" link
                        • Removed the "Support the App" pages
                        • Removed the "Support the App" pop up
                        • Removed "Other Apps" section
                        """).font(.caption)
                }
                
                Divider()
                
                Section {
                    Text("Release 2025.10.1")
                        .font(.headline)
                    Text("Release Date: October 2025")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Added "Actions" section in menu
                    • Add "Bulk Tag" action to add tags to multiple ideas at once
                    • Add "Bulk Archive Ideas" action to Archive multiple ideas at once
                    • Updated the idea view to be more stylized
                    • Updated the tags icons to be the same across the app
                    • Fixed Add / Edit Idea view keyboard bug
                    • Fixed Notes bug
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Release 2025.09.2")
                        .font(.headline)
                    Text("Release Date: September 2025")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Added Tags to be able to filter and organize ideas and projects
                    • Added "Tags" under the management menu to update and manage
                    • Fixed small bug with images
                    • Fixed App label from "Ideaful Debug" to "Ideaful"
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Release 2025.09.1")
                        .font(.headline)
                    Text("Release Date: September 2025")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Added support for iOS26 and Liquid Glass
                    • Added support for landscape viewing on iPad
                    • Added Support Popup every 10 launches
                    • Added Documentation link in the Setting
                    • Updated Images to use CloudKit rather than to default to local storage
                    • Updated  statuses to be pill shape
                    • Updated the review popup to show on the 2nd and 5th launch
                    • Fixed Project button to include name in "All Uncompleted Tasks" View
                    • Fixed all SVG icons (crisper looking now)
                    • Disabled Scroll on Idea Description.
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 4.3.0")
                        .font(.headline)
                    Text("Release Date: June 10th, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Added Chinese, Japanese, Korean, Portuguese, and Hindi translations
                    • Removed "Help Center" button, just email support
                    • Removed "Afterwards" from Other Apps
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 4.2.0")
                        .font(.headline)
                    Text("Release Date: April 11th, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Added statuses for Seeking Funding, Funded, Pitching, Validated, and Under Review
                    • Fixed the title entry when adding a new idea
                    • Fixed the description entry when adding a new idea
                    • Fixed the "Sunsetting" status
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 4.1.3")
                        .font(.headline)
                    Text("Release Date: February 2nd, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Fixed app name to removed "Debug"
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 4.1.2")
                        .font(.headline)
                    Text("Release Date: January 31st, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Fixed Title entry not allowing more than one line
                    • Fixed Desc character count spacing issue
                    • Found Critical bugs with Achievements and Statistics
                        • Disabled Achievements
                        • Disabled Statistics
                        • Disabled Idea Statistics
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 4.1.1")
                        .font(.headline)
                    Text("Release Date: December 30th, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                    • Updated report bug link
                    • Updated request feature link
                    """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 4.1.0")
                        .font(.headline)
                    Text("Release Date: October 20, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                        • Added a new button to add photo inspiration to ideas
                        • Added the description to show under the task title
                        • Added setting to disable delete prompt for ideas
                        • Added tap away for title and description text to unfocus
                        • Added high contrast status text toggle (In Status Setting)
                        • Updated Idea description limit from 75 to 85 characters
                        • Updated Note text preview from 72 to 85 characters
                        • Updated Notes line to be thinner
                        • Updated Idea title and description to unfocus when hitting return
                        • Changed the yellow status color to orange for better readability 
                        • Slight UI change to the Idea Notes section
                        • Fixed text scroll on idea title and description
                        • Fixed idea view pushing up when typing
                        • Fixed starting status being disabled
                        • Fixed statuses list updating instantly when enabling or disabling
                        • Fixed Ideas with ghost data, specific to notes
                        • Fixed swiping to delete tasks in the idea view
                        • Fixed missing icon in Features settings
                        • General fixes
                        """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 4.0.0")
                        .font(.headline)
                    Text("Release Date: October 16, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                        • Added buttons for confirming and canceling new ideas
                        • Added visual for overdue tasks (Uncompleted overdue task circle is now red)
                        • Added statuses for Troubleshooting, Documentation and Sunsetting
                        • Added expanded new task option (tp the plus while entry is empty)
                        • Added a button to collapse the Idea Task overview panel.
                        • Added swipe to delete ideas
                        • Rebuilt Idea View
                        • Rebuilt the Idea Task View
                        • Rebuilt Status views and theme
                        • Fixed Dashboard top bar
                        • Fixed data migrations to prevent re-running
                        • Fixed button spacing
                        • Removed Theme and Status customization
                        • Removed the need for promo codes and unlocks for App Icons
                        • Removed Unlocking Icons Notifications
                        • General code cleanup
                        """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 3.5.0")
                        .font(.headline)
                    Text("Release Date: September 13, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                        • Added support for iOS 18
                        • Added help center link
                        • Updated Privacy and Terms links to new website
                        • Updated "Yarn" Icon 
                        """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 3.4.0")
                        .font(.headline)
                    Text("Release Date: August 27th, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                        • Added "Images" to ideas. Add up to 10 images.
                        • Added "Help Center" in Settings. Links to help page.
                        • Fixed "Setting" item visual error.
                        • Fixed iCloud Bug
                        • Fixed "Other Apps" for "Fundful"
                        """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 3.3.2")
                        .font(.headline)
                    Text("Release Date: August 5th, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                        • Updated Term of Service is now hosted outside the app.
                        • Updated Privacy Policy is now hosted outside the app.
                        """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 3.3.1")
                        .font(.headline)
                    Text("Release Date: July 15th, 2024")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("""
                        • Fixed Other Apps section
                        """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 3.3.0")
                        .font(.headline)
                        
                    Text("Release Date: June 27th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Added Task Reminder
                        • Added Task Due Date
                        • Added Notifications for both Due Date and Reminders on Tasks
                        • Added Task Priority
                        • Added Task Info button to show or hide task details
                        • Added Task Overdue bucket
                        • Added Status themes, which include seven options
                        • Added Notifications in settings.
                        • Added options to disable on-phone notifications for reminders and due dates
                        • Added four new app icons
                        • Updated the Task Dashboard to include more information.
                        • Updated Data Model from Ideaful 2 to Ideaful 3
                        • Updated Task Icons to match the rest of the app
                        • Updated Task list to show High to low Priority in Alphabetical order
                        • Updated "Pencil" App Icon
                        • Fixed Statistics title Notes that were marked Tasks
                        • Fixed notes title expanding vertically instead of horizontally
                        • Fixed some behind-the-scenes code
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 3.2.1")
                        .font(.headline)
                        
                    Text("Release Date: June 16th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Fixed achievement duplication bug
                        """).font(.caption)
                }
                
                Divider().padding()
                
                Section {
                    Text("Version 3.2.0")
                        .font(.headline)
                        
                    Text("Release Date: June 15th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Added App Icon customization (16 Icons)
                        • Added a new notes system (Prior notes will be migrated)
                        • Added auto save to ideas and notes
                        • Added Info button on Idea View
                        • Added Icon Unlock Notifications
                        • Added Achievement Notifications
                        • Added setting in features to turn off notifications
                        • Added Achievement Notifications
                        • Updated in-app notification style
                        • Updated to status colors
                        • Updated some UI colors
                        • Updated model to include data for the number of tasks and notes created, completed, and deleted
                        • Updated Dashboard task button to prevent missed taps
                        • Fixed achievements update bug
                        • Fixed language View
                        • Fixed Cancelled and Completed statistic bug
                            • Any idea set to either of these please change the status to something else and then back to track the statistic.
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 3.1.0")
                        .font(.headline)
                        
                    Text("Release Date: June 3rd, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Added Task Count for All Uncompleted Task button (dashboard)
                        • Added toggle to enable or disable dashboard task count
                        • Added toggle to enable or disable idea task count
                        • Added Auto Save to Ideas (Title, Desc and Notes)
                        • Added Language options within settings
                            • Added French, German, and Spanish
                        • Removed Checkmark Button to save dea when editing
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 3.0.0")
                        .font(.headline)
                        
                    Text("Release Date: May 30th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Added Dashboard Uncompleted Task View (Must have tasks enabled)
                            • This view shows all uncompleted tasks for all your ideas.
                        • Added uncompleted task count in Idea view
                            • Disable or enable task count within the settings
                        • Added divider between idea items to help visually separate things
                        • Added status styling from the dashboard to idea views
                        • Added "Ideation" "Prototyping" "Marketing" and "Abandoned" statuses
                        • Removed "Done Typing" feature as it was broken. Use keyboard return instead
                        • Removed "Import Ideas" function
                        • Rebuilt Export from scratch.
                            • Export TXT, MD and CSV
                        • Updated customization panel in settings
                        • Updated idea deletion. You can now delete an idea that is set to any status and not just canceled
                        • Updated some icons within the settings menu
                        • Updated task icons within the idea view
                        • Updated UI alignments
                        • Fixed task deletion bug
                        • Fixed editing tasks styling
                        • Fixed disabled statuses still showing in status lists
                        • General code cleanup
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 2.4.1")
                        .font(.headline)
                        
                    Text("Release Date: April 18th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Adjusted review prompt to show after 7th and 12th launch of the app
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 2.4.1")
                        .font(.headline)
                        
                    Text("Release Date: April 16th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Added Apple PrivacyInfo
                        • Updated settings icons
                        • Updated "Other Apps"
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 2.3.1")
                        .font(.headline)
                        
                    Text("Release Date: March 8th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Removed "Buy Me A Matcha" Button
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 2.3.0")
                        .font(.headline)
                        
                    Text("Release Date: March 7th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Fixed icon
                        • Tweaked the UI icons once again to make it cleaner
                        • Cleaned up and simplified idea view to be less cluttered
                        • Simplified task view to be less cluttered
                        • Adding a task description has been moved to editing a task to make adding a task cleaner
                        • A review popup will show on the 2nd and 4th launch then never again
                        • Fixed critical bug that made it so you couldn't disable statuses
                        • Support email now opens default mail app instead of forcing Apple Mail
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 2.2.0")
                        .font(.headline)
                        
                    Text("Release Date: February 20th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Updated icons to be more consistent and simpler
                        • Quick tool to quickly dismiss the keyboard
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 2.1.0")
                        .font(.headline)
                        
                    Text("Release Date: February 20th, 2024")
                        .font(.subheadline)
                        
                    Text("""
                        • Updated logo and icon
                        • Overhaul to Idea/Project Page
                        • Overhaul to Tasks Page
                        • Added Phrases at the top
                        • Fixed status selected bug that closed idea when new status was selected
                        • Fixed status selected bug that didnt show current status when selecting
                        • iCloud Backup is re-enabled
                        • Updated Terms of Service
                        • Updated Privacy Policy
                        • Bug fixes
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 2.0.0")
                        .font(.headline)
                        
                    Text("Release Date: December 3rd, 2023")
                        .font(.subheadline)
                        
                    Text("""
                        • New Icon and Logo
                        • Added Task Descriptions to Tasks
                        • Added "Cancel" and "Save" buttons when editing tasks.
                        • Center Task and Task Description within bounds
                        • Tap to Edit Tasks instead of swiping
                        • Moved "Clear" button from top to inline with completed tasks.
                        • Added Deferred, Awaiting Resources, Blocked, Released, and Maintenance as new statuses.
                        • Fixed Ideas not showing on Dashboard in certain situations
                        • Fixed importing ideas permission issue
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 1.4.0")
                        .font(.headline)
                        
                    Text("Release Date: December 1st, 2023")
                        .font(.subheadline)
                        
                    Text("""
                        • General changes
                        • Updated Support Section
                        • Removed iCloud support (Causing data sync issues)
                        • Hid the Import function (Apple Sandboxing is creating permission issues on importing data)
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 1.3.1")
                        .font(.headline)
                        
                    Text("Release Date: October 26th, 2023")
                        .font(.subheadline)
                        
                    Text("""
                        • iPad Release
                        • Updated Icon
                        • Updated Color Schemes
                        • Updated Tasks and Clear buttons
                        • Removed task edit icon
                        • Added Swipe right on task to edit
                        • Added idea status count
                        • Fix Short Desc in New Idea
                        • All statuses are enabled by default
                        • Added Versioning log
                        • Added Other Apps Section
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 1.2.0")
                        .font(.headline)
                        
                    Text("Release Date: September 12th, 2023")
                        .font(.subheadline)
                        
                    Text("""
                        • Fixed statuses to display correctly
                        • Fixed status logic
                        • Added status logic
                        • Continued to update UI visuals
                        • Added in-app notification system
                        • General bug fixes
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 1.1.0")
                        .font(.headline)
                        
                    Text("Release Date: September 9th, 2023")
                        .font(.subheadline)
                        
                    Text("""
                        • Updated Icon
                        • General Code improvements
                        """).font(.caption)
                }
                
                Divider()
                    .padding()
                
                Section {
                    Text("Version 1.0.0")
                        .font(.headline)
                        
                    Text("Release Date: September 2nd, 2023")
                        .font(.subheadline)
                        
                    Text("""
                        • Initial Release
                        """).font(.caption)
                }
            }
            .padding()
            .navigationTitle("Verizon History".localized)
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
}
