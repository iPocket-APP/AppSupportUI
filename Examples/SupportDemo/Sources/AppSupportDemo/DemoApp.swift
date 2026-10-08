import AppSupportCore
import AppSupportUI
import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup("AppSupportUI Validation") { DemoView() }
            .defaultSize(width: 520, height: 760)
    }
}

private struct DemoView: View {
    @State private var language = "en"
    @State private var rejectLinks = true
    @State private var lastResult = ""
    private let identity = AppIdentity(name: "Demo", version: "2.0.0", build: "42")

    private var copy: SupportCopy {
        if language != "ar" { return .packageDefaults(appName: identity.name, language: language) }
        return SupportCopy(
            sectionTitle: "الدعم", versionTitle: "الإصدار", unknownVersion: "غير معروف",
            rate: .init(title: "تقييم التطبيق", subtitle: "شارك رأيك في متجر التطبيقات"),
            contact: .init(title: "الاتصال بالدعم", subtitle: "احصل على مساعدة بشأن التطبيق"),
            contactWebsite: .init(title: "موقع الدعم"), privacy: .init(title: "سياسة الخصوصية"),
            terms: .init(title: "شروط الاستخدام"), website: .init(title: "الموقع الإلكتروني"),
            mail: .init(subject: "دعم Demo", prompt: "يرجى وصف المشكلة فوق هذا السطر.", appLabel: "التطبيق",
                        versionLabel: "الإصدار", buildLabel: "البنية", systemLabel: "النظام", deviceLabel: "الجهاز"),
            failure: .init(title: "تعذر الفتح", message: "تعذر على النظام فتح الرابط. استخدم خيار دعم آخر.",
                           copyEmail: "نسخ عنوان البريد", copyDiagnostics: "نسخ تفاصيل الدعم",
                           contactWebsite: "فتح موقع الدعم", close: "إغلاق", copied: "تم النسخ")
        )
    }

    private var content: SupportContent {
        SupportContent(identity: identity, links: .init(
            email: "support+demo@example.com", contactURL: URL(string: "https://example.com/contact"),
            privacyURL: URL(string: "https://example.com/privacy"), termsURL: URL(string: "https://example.com/terms"),
            websiteURL: URL(string: "https://example.com"), appStoreID: "123456789"
        ), copy: copy)
    }

    var body: some View {
        NavigationStack {
        Form {
            Section("Validation controls") {
                Picker("Content language", selection: $language) {
                    Text("English").tag("en")
                    Text("简体中文").tag("zh-Hans")
                    Text("العربية (host copy)").tag("ar")
                }
                .accessibilityIdentifier("demo.language")
                Toggle("Simulate rejected URLs", isOn: $rejectLinks)
                    .accessibilityIdentifier("demo.reject")
                Text(lastResult).font(.caption).accessibilityIdentifier("demo.result")
            }
            Section {
                AppIdentityHeader(identity: identity, copy: copy, showBuildNumber: true) {
                    Image(systemName: "app.fill").font(.largeTitle)
                }
            }
            SupportSection(content: content, showBuildNumber: true,
                           onStart: { _ in lastResult = "Started" },
                           onResult: { _, result in lastResult = "Result: \(result)" })
            Section("Host composition") {
                NavigationLink {
                    Text("Host-owned native destination")
                } label: {
                    SupportRowLabel(title: copy.privacy.title, systemImage: "hand.raised", accessory: .none)
                }
                DisclosureGroup("Host-owned licenses") { Text("MIT License") }
            }
        }
        .formStyle(.grouped)
        .environment(\.locale, Locale(identifier: language))
        .environment(\.layoutDirection, language == "ar" ? .rightToLeft : .leftToRight)
        .environment(\.openURL, OpenURLAction { _ in rejectLinks ? .discarded : .handled })
        .frame(minWidth: 320, minHeight: 600)
        }
    }
}
