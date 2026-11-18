import SwiftUI

/// Three steps: who you are, where you play, where you're headed.
struct OnboardingView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: PlayerProfile
    @State private var step = 0
    @State private var error = ""
    var isEditing = false

    init(existing: PlayerProfile? = nil) {
        _draft = State(initialValue: existing ?? PlayerProfile())
        isEditing = existing != nil
    }

    private let titles = ["Who's training?", "Where do you play?", "Where are you headed?"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Kicker(text: "Player profile · step \(step + 1) of 3")
                    Text(titles[step]).font(.system(size: 38, weight: .black, design: .rounded))
                    switch step {
                    case 0: you
                    case 1: positions
                    default: level
                    }
                    if !error.isEmpty { Text(error).foregroundStyle(.red).font(.subheadline.weight(.semibold)) }
                    HStack {
                        if step > 0 { Button("Back") { error = ""; step -= 1 }.buttonStyle(BigButtonStyle(filled: false)) }
                        Button(step == 2 ? (isEditing ? "Save" : "Build my dashboard") : "Next") { next() }
                            .buttonStyle(BigButtonStyle())
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
            .toolbar {
                if isEditing { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            }
        }
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }

    private var you: some View {
        VStack(alignment: .leading, spacing: 12) {
            field("Name", $draft.name, .name)
            field("Email", $draft.email, .emailAddress, keyboard: .emailAddress)
            field("Phone", $draft.phone, .telephoneNumber, keyboard: .phonePad)
            HStack {
                Text("AGE GROUP").font(.caption.weight(.semibold).monospaced()).foregroundStyle(.secondary)
                Spacer()
                Picker("Age group", selection: $draft.age) {
                    ForEach(["U12", "U13", "U14", "U15", "U16", "U17", "U19"], id: \.self) { Text($0) }
                }
            }
            .padding(.leading, 12).padding(.vertical, 4)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text("STRONG FOOT").font(.caption.weight(.semibold).monospaced()).foregroundStyle(.secondary)
            Picker("Strong foot", selection: $draft.foot) {
                ForEach(["Right", "Left", "Both"], id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            Text("Saved only on this phone.").font(.footnote).foregroundStyle(.secondary)
        }
    }

    private func field(_ label: String, _ text: Binding<String>, _ type: UITextContentType, keyboard: UIKeyboardType = .default, placeholder: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(.caption.weight(.semibold).monospaced()).foregroundStyle(.secondary)
            TextField(placeholder ?? label, text: text)
                .textContentType(type)
                .keyboardType(keyboard)
                .textInputAutocapitalization(type == .name ? .words : .never)
                .autocorrectionDisabled()
                .padding(12)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var positions: some View {
        let order = [draft.primary, draft.secondary, draft.third]
        var ranks: [String: Int] = [:]
        for (i, c) in order.enumerated() where !c.isEmpty { ranks[c] = i + 1 }
        return VStack(alignment: .leading, spacing: 14) {
            Text("Tap your main position, then your second and third. Tap again to clear.").foregroundStyle(.secondary)
            PitchPicker(picked: ranks) { spot in pick(spot.code) }
            ForEach(0..<3) { i in
                HStack {
                    Text(["MAIN", "SECOND", "THIRD"][i]).font(.caption.weight(.bold).monospaced()).foregroundStyle(.secondary).frame(width: 70, alignment: .leading)
                    Text(Spot.find(order[i])?.label ?? "not set").font(.headline).foregroundStyle(order[i].isEmpty ? .secondary : .primary)
                }
            }
        }
    }

    private func pick(_ code: String) {
        var order = [draft.primary, draft.secondary, draft.third]
        if let i = order.firstIndex(of: code) {
            order.remove(at: i); order.append("")
        } else if let free = order.firstIndex(of: "") {
            order[free] = code
        } else {
            order[2] = code
        }
        draft.primary = order[0]; draft.secondary = order[1]; draft.third = order[2]
    }

    private var level: some View {
        VStack(alignment: .leading, spacing: 14) {
            levelPicker("Level you play now", $draft.current)
            field("Team / division (optional)", $draft.team, .organizationName, placeholder: "e.g. N1, U15 Red")
            levelPicker("Level you want to reach", $draft.goal)
            Picker("Region", selection: $draft.region) {
                ForEach(["East", "Central", "West"], id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    private func levelPicker(_ label: String, _ value: Binding<Level>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(.caption.weight(.semibold).monospaced()).foregroundStyle(.secondary)
            Picker(label, selection: value) {
                ForEach(Level.allCases) { Text($0.name).tag($0) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func next() {
        draft.name = draft.name.trimmingCharacters(in: .whitespaces)
        switch step {
        case 0:
            if draft.name.isEmpty { error = "Add your name."; return }
            if !draft.email.isEmpty && draft.email.range(of: #"^\S+@\S+\.\S+$"#, options: .regularExpression) == nil { error = "That email doesn't look right."; return }
            if !draft.phone.isEmpty && draft.phone.filter(\.isNumber).count < 10 { error = "Phone number needs at least 10 digits."; return }
        case 1:
            if draft.primary.isEmpty { error = "Tap your main position on the pitch."; return }
        default:
            if draft.goal.rank <= draft.current.rank { error = "Pick a goal level above where you play now."; return }
            store.saveProfile(draft)
            dismiss()
            return
        }
        error = ""
        step += 1
    }
}

struct ProfileView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var editing = false
    @State private var confirmDelete = false
    @State private var focusError = ""

    var body: some View {
        NavigationStack {
            Group {
                if let p = store.profile {
                    List {
                        Section("Player") {
                            row("Name", p.name); row("Email", p.email); row("Phone", p.phone)
                            row("Age group", p.age); row("Strong foot", p.foot)
                        }
                        Section("Positions") {
                            row("Main", Spot.find(p.primary)?.label ?? "—")
                            row("Second", Spot.find(p.secondary)?.label ?? "—")
                            row("Third", Spot.find(p.third)?.label ?? "—")
                        }
                        Section("Level") {
                            row("Plays now", p.current.name + (p.team.isEmpty ? "" : " · \(p.team)"))
                            row("Goal", "\(p.goal.name) · \(p.region)")
                        }
                        Section {
                            let skills = p.mainPosition.info.coreSkills + Skill.allCases.filter {
                                !p.mainPosition.info.coreSkills.contains($0) && ($0.isKeeper == (p.mainPosition == .gk))
                            }
                            FlowLayout(spacing: 6) {
                                ForEach(skills) { s in
                                    let on = p.focusSkills.contains(s)
                                    Button(s.name) { toggleFocus(s, p) }
                                        .font(.footnote.weight(.semibold))
                                        .padding(.horizontal, 10).padding(.vertical, 7)
                                        .foregroundStyle(on ? .black : .white)
                                        .background(on ? Theme.accent : Theme.cardStrong, in: Capsule())
                                        .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                            if !focusError.isEmpty { Text(focusError).font(.footnote).foregroundStyle(.red) }
                        } header: { Text("What you're working on") } footer: { Text("Pick up to three. Today's plan builds around them.") }
                        Section {
                            Button("Edit profile") { editing = true }
                            Button("Delete my profile", role: .destructive) { confirmDelete = true }
                        }
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    ContentUnavailableView("No profile yet", systemImage: "person.crop.circle")
                }
            }
            .background(Theme.background)
            .navigationTitle("Player profile")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
            .sheet(isPresented: $editing) { OnboardingView(existing: store.profile) }
            .confirmationDialog("Delete your profile and Pathway sessions from this phone?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    store.data.profile = nil
                    store.data.pathwaySessions = nil
                    dismiss()
                }
            }
        }
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }

    private func row(_ label: String, _ value: String) -> some View {
        LabeledContent(label, value: value.isEmpty ? "—" : value)
    }

    private func toggleFocus(_ s: Skill, _ p: PlayerProfile) {
        var picked = p.focusSkills
        if let i = picked.firstIndex(of: s) { picked.remove(at: i) }
        else if picked.count >= 3 { focusError = "Three at most — focus wins."; return }
        else { picked.append(s) }
        focusError = ""
        var updated = p
        updated.focus = picked
        store.saveProfile(updated)
    }
}
