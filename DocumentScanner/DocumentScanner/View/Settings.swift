//
//  Settings.swift
//  DocumentScanner
//
//  Created by Fenuku kekeli on 5/23/25.
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) private var dismiss  // For dismissing the view
    
    var body: some View {
        NavigationStack {
            Form {
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
              
                
                // Feedback Section
                Section(header: Text("Feedback")) {
                  
                    
                    Button {
                        // Rate the app action
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Rate the App", systemImage: "star")
                    }
                }
                
                // About Section
                Section {
                    NavigationLink {
                        InfoView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                    
                    Link(destination: URL(string: "mailto:fenuku.kekeli8989@gmail.com")!) {
                        Label("Email Support", systemImage: "envelope")
                    }

                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()  // Dismiss the view
                    }
                }
            }
            .toggleStyle(.switch)  // Updated toggle style
        }
    }
}

struct InfoView: View {
    var body: some View {
        Form {
            // Version Information
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Build Number")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1001")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Legal Information
            Section(header: Text("Legal")) {
                Link("Privacy Policy",
                     destination: URL(string: "https://docs.google.com/document/d/e/2PACX-1vSta1b2qmL7rXnwLEJCL6hbX0luqyPxbpMIZqc4SAe7O769-4a_q48x2h8rDGqNn3EacIukj05DcY2S/pub")!)
                Link("Terms of Service",
                     destination: URL(string: "https://docs.google.com/document/d/e/2PACX-1vR95ELoVWcXoucRyZYnsd43sFGpzrN-hNeBwioXqLIVy8pz9So2d8u-CNbXcRBCSpQbyYFKPsRRbhjI/pub")!)
            }
            
            // Developer Information
        
            Section(header: Text("Socials")) {
                Link("Follow us on Twitter", destination: URL(string: "https://x.com/fenukukekeli?s=21&t=axe1i0ScNpywV3tKXHGQIA")!)
                Link("Check out our Instagram", destination: URL(string: "https://www.instagram.com/__.kelidev?igsh=b3VuMDB2bjJxcXI2&utm_source=qr")!)
                Link("Connect on LinkedIn", destination: URL(string: "https://www.linkedin.com/in/kekeli-fenuku-908a28250?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app")!)
                Link("Watch on TikTok", destination: URL(string: "https://www.tiktok.com/@keli.dev?_t=ZM-8wbiUrWrxiv&_r=1")!)
                Link("Subscribe on YouTube", destination: URL(string: "https://youtube.com/@keliiosdev?si=BjaWcNFoTHtcyDJT")!)
            }
            
            // Copyright Footer
            Section {
                Text("© \(Calendar.current.component(.year , from: Date())) Your Company Name")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .bold()
            }

        }
        .navigationTitle("App Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Provider
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
