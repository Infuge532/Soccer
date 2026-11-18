import SwiftUI

/// The main screen: pick what to work on today, say what you have with you,
/// and get every drill that fits.
struct TrainView: View {
    @EnvironmentObject private var store: Store
    @State private var path: [String] = []
    @State private var warmupOpen = false

    private var setup: Setup { store.data.setup }
    private var picked: [Focus] { store.today.focuses }

    /// Every drill you can do today, in the order shown, for "Next drill".
    private var queue: [String] {
        picked.flatMap { Library.drills(for: $0).filter { $0.fits(setup) }.map(\.id) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    focusPicker
                    setupPicker
                    if picked.isEmpty {
                        emptyState
                    } else {
                        summary.id("summary")
                        warmupCard
                        ForEach(picked) { focus in
                            FocusSection(focus: focus, setup: setup)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 20)
            }
            #if DEBUG
            .onAppear {
                // Screenshot helpers: "-scrollDrills" jumps to the list, "-showDrill ID" opens one.
                let args = CommandLine.arguments
                if args.contains("-scrollDrills") { reader.scrollTo("summary", anchor: .top) }
                if let i = args.firstIndex(of: "-showDrill"), i + 1 < args.count { path = [args[i + 1]] }
            }
            #endif
            }
            .background(Theme.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { id in
                if let drill = Library.drill(id) {
                    DrillDetailView(drill: drill, queue: queue, path: $path)
                }
            }
        }
        .onAppear { Reminders.pendingStart = false }
        // Today's reminders are skipped once you've done a drill.
        .onChange(of: store.today.trained) { _, _ in Reminders.refresh(store: store) }
        .onReceive(NotificationCenter.default.publisher(for: .startTodayWorkout)) { _ in
            Reminders.pendingStart = false
            path = []
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                Text("TODAY'S TRAINING")
                    .font(.display(44))
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                Text("\(store.streak)")
                    .monospacedDigit()
            }
            .font(.headline)
            .foregroundStyle(store.streak > 0 ? Theme.accent : .secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Theme.card, in: Capsule())
            .accessibilityLabel("Streak: \(store.streak) days")
        }
        .padding(.top, 8)
    }

    // MARK: Pickers

    private var focusPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionTitle(text: "What do you want to work on?")
                Spacer()
                if !picked.isEmpty {
                    Button("Clear") {
                        withAnimation(.snappy) { store.clearFocuses() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .tint(Theme.accent)
                }
            }
            Text("Pick one or more.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, -8)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Focus.allCases) { focus in
                    FocusTile(focus: focus,
                              selected: picked.contains(focus),
                              available: Library.drills(for: focus).filter { $0.fits(setup) }.count) {
                        withAnimation(.snappy) { store.toggleFocus(focus) }
                    }
                }
            }
        }
    }

    private var setupPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: "What have you got today?")
            HStack(spacing: 0) {
                PlaceButton(title: "Inside", symbol: "house.fill", selected: !setup.outside) {
                    if setup.outside { store.toggleNeed(.outside) }
                }
                PlaceButton(title: "Outside", symbol: "sun.max.fill", selected: setup.outside) {
                    if !setup.outside { store.toggleNeed(.outside) }
                }
            }
            .padding(4)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            HStack(spacing: 10) {
                ForEach([Need.goal, .partner, .wall]) { need in
                    NeedChip(need: need, on: setup.has(need)) { store.toggleNeed(need) }
                }
            }
        }
    }

    // MARK: Drills

    private var emptyState: some View {
        Card {
            Label("Pick something above", systemImage: "hand.point.up.left.fill")
                .font(.headline)
                .foregroundStyle(Theme.accent)
            Text("Choose what you want to get better at today and the drills that fit what you've got show up here. You can pick something different every day.")
                .foregroundStyle(.secondary)
        }
    }

    private var summary: some View {
        let ids = queue
        let done = ids.filter(store.isDone).count
        let minutes = ids.compactMap(Library.drill).reduce(0) { $0 + $1.minutes }
        return HStack(spacing: 14) {
            ZStack {
                Circle().stroke(Color.white.opacity(0.12), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: ids.isEmpty ? 0 : Double(done) / Double(ids.count))
                    .stroke(Theme.accent, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(done)")
                    .font(.headline.bold())
                    .monospacedDigit()
            }
            .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(picked.map(\.name).joined(separator: " + "))
                    .font(.headline)
                    .lineLimit(2)
                Text("\(done) of \(ids.count) drills done · about \(minutes) min for all of them")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var warmupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) { warmupOpen.toggle() }
            } label: {
                HStack {
                    Label("Warm up first · 6-8 min", systemImage: "flame")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(warmupOpen ? 180 : 0))
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if warmupOpen {
                ForEach(Library.warmup) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Circle().fill(Theme.accent).frame(width: 6, height: 6)
                            .alignmentGuide(.firstTextBaseline) { $0[.bottom] + 4 }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name).font(.body.weight(.semibold))
                            Text(item.detail).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Pieces

private struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.display(24)).foregroundStyle(Theme.accent)
    }
}

private struct FocusTile: View {
    let focus: Focus
    let selected: Bool
    let available: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: focus.symbol)
                    .font(.body.weight(.semibold))
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 1) {
                    Text(focus.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(focus.name.contains(" ") ? 2 : 1)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.leading)
                    Text("\(available) drill\(available == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(selected ? Color.black.opacity(0.65) : .secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? Color.black : Color.white.opacity(0.3))
            }
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .foregroundStyle(selected ? Color.black : Color.white)
            .background(selected ? Theme.accent : Theme.card,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selected)
        .accessibilityLabel("\(focus.name), \(available) drills")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct PlaceButton: View {
    let title: String
    let symbol: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .foregroundStyle(selected ? Color.black : Color.white.opacity(0.75))
                .background(selected ? Theme.accent : Color.clear,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct NeedChip: View {
    let need: Need
    let on: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: need.symbol)
                    .font(.title3)
                Text(need == .partner ? "Partner" : need.name)
                    .font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(on ? Color.black : Color.white.opacity(0.75))
            .background(on ? Theme.accent : Theme.card,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: on)
        .accessibilityLabel("\(need.name), \(on ? "have it" : "don't have it")")
    }
}

/// One picked focus: its drills that fit today, and a note about the ones that don't.
private struct FocusSection: View {
    @EnvironmentObject private var store: Store
    let focus: Focus
    let setup: Setup

    var body: some View {
        let all = Library.drills(for: focus)
        let fits = all.filter { $0.fits(setup) }
        let locked = all.filter { !$0.fits(setup) }
        let done = fits.filter { store.isDone($0.id) }.count

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(focus.name.uppercased(), systemImage: focus.symbol)
                    .font(.display(24))
                Spacer()
                Text("\(done)/\(fits.count)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(done == fits.count && done > 0 ? Theme.accent : .secondary)
            }
            ForEach(fits) { drill in
                DrillRow(drill: drill)
            }
            if !locked.isEmpty {
                Text(lockedText(locked))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
        }
    }

    private func lockedText(_ locked: [Drill]) -> String {
        let missing = Need.allCases.filter { need in
            !setup.has(need) && locked.contains { $0.needs.contains(need) }
        }
        let words = missing.map { need -> String in
            switch need {
            case .outside: return "being outside"
            case .goal: return "a goal"
            case .partner: return "a partner"
            case .wall: return "a wall"
            }
        }
        let list = words.count <= 1 ? words.joined()
            : words.dropLast().joined(separator: ", ") + " or " + (words.last ?? "")
        return "+\(locked.count) more drill\(locked.count == 1 ? "" : "s") with \(list)."
    }
}

private struct DrillRow: View {
    @EnvironmentObject private var store: Store
    let drill: Drill

    var body: some View {
        let done = store.isDone(drill.id)
        HStack(spacing: 4) {
            Button {
                withAnimation(.snappy) { store.toggleDone(drill.id) }
            } label: {
                CheckCircle(done: done)
                    .padding(.leading, 14)
                    .padding(.vertical, 14)
                    .padding(.trailing, 6)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.success, trigger: done) { _, new in new }
            .accessibilityLabel("\(drill.name), \(done ? "done" : "not done")")

            NavigationLink(value: drill.id) {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(drill.name)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(done ? Color.white.opacity(0.55) : .white)
                            .strikethrough(done, color: .white.opacity(0.4))
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 8) {
                            Text("\(drill.amount) · \(drill.minutes) min")
                            ForEach(Need.allCases.filter { drill.needs.contains($0) }) { need in
                                Image(systemName: need.symbol)
                                    .accessibilityLabel(need.name)
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 14)
                .padding(.trailing, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
