import SwiftUI

/// Three steps: who you are, where you play, where you're headed.
struct OnboardingView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var draft: PlayerProfile
    @State private var step = 0
    @State private var error = ""
    @State private var welcome: Bool
    var isEditing = false

    init(existing: PlayerProfile? = nil) {
        _draft = State(initialValue: existing ?? PlayerProfile())
        _welcome = State(initialValue: existing == nil)
        isEditing = existing != nil
    }

    private let titles = ["Who's training?", "Where do you play?", "Where are you headed?"]
    private let subtitles = ["Your name goes on your player card.", "Your main position sets the stats on your card.", "We'll show you what the next level looks for."]

    var body: some View {
        ZStack {
            if welcome {
                welcomeScreen.transition(.opacity)
            } else {
                form.transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.4), value: welcome)
        .tint(Theme.accent)
        .preferredColorScheme(.dark)
    }

    private var welcomeScreen: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer(minLength: 0)
            Text("WELCOME TO KEEPER,\nLET'S GET STARTED")
                .font(.display(50))
                .lineLimit(2)
                .minimumScaleFactor(0.5)
            Text("Build your player card, find drills for your position and train at home. Every finished drill raises your stats.")
                .font(.body)
                .foregroundStyle(Theme.muted)
                .minimumScaleFactor(0.8)
            ArrowSquareButton { welcome = false }
                .padding(.top, 14)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background {
            ZStack {
                Theme.background
                StadiumBackdrop(fade: 0.42)
            }
            .ignoresSafeArea()
        }
    }

    private var form: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        StadiumBackdrop(fade: 0.35).frame(height: 300)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                ForEach(0..<3) { i in
                                    Capsule().fill(i <= step ? Theme.accent : Color.white.opacity(0.18)).frame(height: 4)
                                }
                            }
                            .frame(width: 120)
                            Text(titles[step].uppercased()).font(.display(46)).minimumScaleFactor(0.7).lineLimit(1)
                            Text(subtitles[step]).foregroundStyle(Theme.muted)
                        }
                        .padding(.horizontal, 20)
                    }
                    VStack(alignment: .leading, spacing: 18) {
                        switch step {
                        case 0: you
                        case 1: positions
                        default: level
                        }
                        if !error.isEmpty { Text(error).foregroundStyle(.red).font(.subheadline.weight(.semibold)) }
                        HStack {
                            if step > 0 { Button("Back") { error = ""; withAnimation { step -= 1 } }.buttonStyle(BigButtonStyle(filled: false)) }
                            Button(step == 2 ? (isEditing ? "Save" : "Build my card") : "Next") { next() }
                                .buttonStyle(BigButtonStyle())
                        }
                    }
                    .padding(20)
                }
            }
            .ignoresSafeArea(edges: .top)
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background)
            .toolbar {
                if isEditing { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
            }
        }
    }

    private var you: some View {
        VStack(alignment: .leading, spacing: 12) {
            field("Name", $draft.name, .name)
            field("Email", $draft.email, .emailAddress, keyboard: .emailAddress)
            field("Phone", $draft.phone, .telephoneNumber, keyboard: .phonePad)
            HStack {
                Text("AGE GROUP").font(.display(15, .bold)).tracking(1).foregroundStyle(Theme.muted)
                Spacer()
                Picker("Age group", selection: $draft.age) {
                    ForEach(["U12", "U13", "U14", "U15", "U16", "U17", "U19"], id: \.self) { Text($0) }
                }
            }
            .padding(.leading, 16).padding(.vertical, 8)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text("STRONG FOOT").font(.display(15, .bold)).tracking(1).foregroundStyle(Theme.muted)
            Picker("Strong foot", selection: $draft.foot) {
                ForEach(["Right", "Left", "Both"], id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            Text("Saved only on this phone.").font(.footnote).foregroundStyle(.secondary)
        }
    }

    private func field(_ label: String, _ text: Binding<String>, _ type: UITextContentType, keyboard: UIKeyboardType = .default, placeholder: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(.display(15, .bold)).tracking(1).foregroundStyle(Theme.muted)
            TextField(placeholder ?? label, text: text)
                .textContentType(type)
                .keyboardType(keyboard)
                .textInputAutocapitalization(type == .name ? .words : .never)
                .autocorrectionDisabled()
                .padding(.horizontal, 16).padding(.vertical, 17)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.line))
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
                    Text(["MAIN", "SECOND", "THIRD"][i]).font(.display(15, .bold)).tracking(1).foregroundStyle(Theme.muted).frame(width: 70, alignment: .leading)
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
            Text(label.uppercased()).font(.display(15, .bold)).tracking(1).foregroundStyle(Theme.muted)
            Picker(label, selection: value) {
                ForEach(Level.allCases) { Text($0.name).tag($0) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
        withAnimation { step += 1 }
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
                        Section {
                            PlayerCard(name: p.firstName, ratings: store.cardRatings(for: p), width: 190)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .listRowBackground(Color.clear)
                        }
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
            .navigationTitle("PLAYER PROFILE")
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
