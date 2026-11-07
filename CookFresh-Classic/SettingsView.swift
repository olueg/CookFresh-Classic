//
//  SettingsView.swift
//  CookFresh-Classic
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("gemini_api_key") private var apiKey: String = ""
    @AppStorage("gemini_model") private var model: String = "gemini-1.5-flash"
    @Environment(\.dismiss) private var dismiss

    private let models = [
        "gemini-1.5-flash",
        "gemini-1.5-pro",
        "gemini-2.0-flash",
        "gemini-pro"
    ]

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
                    Picker("Model", selection: $model) {
                        ForEach(models, id: \.self) { m in
                            Text(m).tag(m)
                        }
                    }
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