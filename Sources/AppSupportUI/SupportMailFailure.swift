import AppSupportCore

struct SupportMailFailure: Identifiable {
    let draft: SupportMailDraft

    var id: String { draft.recipient }
}
