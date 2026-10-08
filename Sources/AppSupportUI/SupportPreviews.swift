import AppSupportCore
import SwiftUI

#if DEBUG
#Preview("Support · 简体中文") {
    let identity = AppIdentity(name: "Demo", version: "1.2.3", build: "42")
    let content = SupportContent(
        identity: identity,
        links: SupportLinks(
            email: "support@example.com",
            contactURL: URL(string: "https://example.com/contact"),
            privacyURL: URL(string: "https://example.com/privacy"),
            appStoreID: "123456789"
        ),
        copy: .packageDefaults(appName: identity.name, language: "zh-Hans")
    )
    Form {
        SupportSection(content: content, showBuildNumber: true)
    }
}

#Preview("About composition") {
    let identity = AppIdentity(name: "Demo", version: "1.2.3", build: "42")
    let content = SupportContent(
        identity: identity,
        links: SupportLinks(websiteURL: URL(string: "https://example.com")),
        copy: .packageDefaults(appName: identity.name, language: "en")
    )
    Form {
        Section {
            AppIdentityHeader(identity: identity, copy: content.copy, showBuildNumber: true) {
                Image(systemName: "app.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
        }
        Section {
            SupportRows(content: content, rows: [.website, .version])
        }
    }
}
#endif
