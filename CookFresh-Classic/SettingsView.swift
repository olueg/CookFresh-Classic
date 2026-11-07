//
//  SettingsView.swift
//  CookFresh-Classic
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("gemini_api_key") private var apiKey: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Gemini") {
                    SecureField("API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
#if os(iOS)
                        .textInputAutocapitalization(.never)
#endif
                }
                Section {
                    Link("Get an API key", destination: URL(string: "https://aistudio.google.com/app/apikey")!)
                }
            }
            .navigationTitle("Settings")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}