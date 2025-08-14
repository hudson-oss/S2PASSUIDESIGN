// S2 Pass – iOS UI Demo (SwiftUI)
// Single‑file prototype you can paste into a fresh Xcode project (iOS App → SwiftUI)
// Xcode 15+, iOS 17+ recommended
//
// Notes:
// • Brand accents are configurable per school via Theme.schoolAccent (default: orange).
// • Buttons and chips auto‑switch label color (black/white) based on contrast.
// • Tabs: Homepage, Events, Your Tickets – as shown in the provided mockups.
// • Replace placeholder images (e.g., "home.logo", "away.logo") with real assets.
// • This is a UI demo only; no networking or auth.

import SwiftUI

@main
struct S2PassUIDesignApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - Theme & Utilities

struct Theme {
    // Default brand accent (S2 amber/orange‑ish). Change at runtime to simulate school colors.
    static var schoolAccent = Color(hex: "#F5A623")
    static let surface = Color(uiColor: .systemBackground)
    static let card = Color(uiColor: .secondarySystemBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let cornerRadius: CGFloat = 16
    static let shadow = Color.black.opacity(0.12)
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

extension Color {
    // Simple perceived luminance for contrast decisions
    var luminance: Double {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Rec. 601 luma approximation
        return 0.299 * r + 0.587 * g + 0.114 * b
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .shadow(color: Theme.shadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Models (Mock Data)

struct School: Identifiable { let id = UUID(); var name: String; var accent: Color }

struct Event: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var homeSchool: School
    var awaySchool: School
    var isHome: Bool
    var ticketsAvailable: Bool
    var location: String
    var details: String = ""
}

struct Ticket: Identifiable {
    let id = UUID()
    var event: Event
    var section: String?
    var quantity: Int
}

// Sample schools & events
let bradford = School(name: "BRADFORD HS", accent: Theme.schoolAccent)
let solidRock = School(name: "SOLID ROCK HS", accent: Color(hex: "#C7B589"))

let sampleEvents: [Event] = {
    let base = DateComponents(calendar: .current, year: 2025, month: 6, day: 30, hour: 20).date ?? .now
    return (0..<4).map { i in
        Event(title: "BOYS BASEBALL (JV/V)",
              date: Calendar.current.date(byAdding: .day, value: i, to: base) ?? base,
              homeSchool: bradford,
              awaySchool: solidRock,
              isHome: i % 2 == 0,
              ticketsAvailable: true,
              location: "123 S2 PASS LANE",
              details: "RESERVED SEATING AVAILABLE")
    }
}()

let sampleTickets: [Ticket] = [
    Ticket(event: sampleEvents.first!, section: nil, quantity: 1)
]

// MARK: - Root

struct RootView: View {
    @State private var selectedTab: Tab = .home
    @State private var accent: Color = Theme.schoolAccent

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView(accent: $accent) }
                .tabItem { Label("Homepage", systemImage: "house.fill") }
                .tag(Tab.home)

            NavigationStack { EventsListView(accent: accent) }
                .tabItem { Label("Events", systemImage: "calendar") }
                .tag(Tab.events)

            NavigationStack { TicketsView(accent: accent) }
                .tabItem { Label("Your Tickets", systemImage: "ticket.fill") }
                .tag(Tab.tickets)
        }
        .tint(accent)
    }

    enum Tab { case home, events, tickets }
}

// MARK: - Home

struct HomeView: View {
    @Binding var accent: Color
    @State private var showColorPicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeaderBar(title: bradford.name, accent: accent) {
                    showColorPicker = true
                }

                SectionHeader(title: "EVENTS:")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(sampleEvents) { event in
                            EventCard(event: event, accent: accent)
                        }
                    }
                    .padding(.horizontal)
                }
                HStack { Spacer(); PillButton(title: "VIEW ALL", accent: accent) {}.padding(.horizontal) }

                SectionHeader(title: "MY TICKETS:")
                VStack(spacing: 12) {
                    ForEach(sampleTickets) { ticket in
                        TicketCard(ticket: ticket, accent: accent)
                    }
                }
                .padding(.horizontal)
                HStack { Spacer(); PillButton(title: "VIEW ALL", accent: accent) {}.padding(.horizontal) }

                SectionHeader(title: "SHOP:")
                VStack(spacing: 12) {
                    ShopCard(title: "STUDENT FEES", accent: accent) {}
                    HStack { Spacer(); Text(dateString(sampleEvents.first!.date)).font(.footnote).foregroundStyle(.secondary) }
                }.padding(.horizontal)

                SectionHeader(title: "CONCESSIONS:")
                HStack { Spacer(); PillButton(title: "GO TO", accent: accent) {}.padding(.horizontal) }

                SectionHeader(title: "NEWS:")
                NewsCard(accent: accent)
                    .padding(.horizontal)
                HStack { Spacer(); PillButton(title: "VIEW ALL", accent: accent) {}.padding(.horizontal) }

                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showColorPicker) {
            VStack(spacing: 16) {
                Text("Customize School Color").font(.headline)
                ColorPicker("Accent", selection: $accent, supportsOpacity: false).labelsHidden()
                Text("UI automatically adjusts label contrast.").font(.footnote).foregroundStyle(.secondary)
                Button("Done") { showColorPicker = false }.buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Homepage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Events List

struct EventsListView: View {
    var accent: Color
    @State private var showFilter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeaderBar(title: "EVENTS", accent: accent) {
                    showFilter = true
                }
                Text("SELECT AN EVENT TO PURCHASE TICKETS").font(.subheadline).fontWeight(.semibold).textCase(.uppercase).padding(.horizontal)

                ForEach(sampleEvents) { event in
                    EventRow(event: event, accent: accent)
                        .padding(.horizontal)
                }
                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showFilter) {
            FilterSheet(accent: accent)
        }
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Event Details

struct EventDetailsView: View {
    var event: Event
    var accent: Color

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HeaderBar(title: "EVENT DETAILS", accent: accent)
                VStack(alignment: .leading, spacing: 16) {
                    // Match top matchup card
                    VStack(spacing: 12) {
                        HStack {
                            Chip(text: event.isHome ? "HOME" : "AWAY", accent: .gray.opacity(0.2), label: .secondary)
                            Spacer()
                            Chip(text: event.isHome ? "AWAY" : "HOME", accent: .gray.opacity(0.2), label: .secondary)
                        }
                        HStack(alignment: .center) {
                            TeamLogoPlaceholder()
                            Text("VS").font(.headline).padding(.horizontal, 12).background(Capsule().fill(.thinMaterial))
                            TeamLogoPlaceholder()
                        }
                        HStack {
                            Text(event.homeSchool.name).font(.caption).fontWeight(.semibold)
                            Spacer()
                            Text(event.awaySchool.name).font(.caption).fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .cardStyle()

                    HStack(spacing: 16) {
                        InfoTile(title: "DATE/TIME", value: dateTimeString(event.date), accent: accent)
                        InfoTile(title: "SPONSOR", value: "Bass Pro Shops", accent: accent, imageSystemName: "fish")
                    }

                    InfoTextField(title: "LOCATION", value: event.location, icon: "mappin.and.ellipse")
                    InfoMultiline(title: "DETAILS", value: event.details)

                    BannerButton(title: "OUR BANNER SPONSOR?", accent: accent) {}
                    CTAButton(title: "PURCHASE TICKETS", accent: accent) {}
                }
                .padding(.horizontal)
                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
        .navigationTitle("Event Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tickets

struct TicketsView: View {
    var accent: Color

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeaderBar(title: "YOUR TICKETS", accent: accent)
                ForEach(sampleTickets) { ticket in
                    TicketCard(ticket: ticket, accent: accent)
                        .padding(.horizontal)
                }
                Spacer(minLength: 24)
            }
            .padding(.vertical)
        }
        .navigationTitle("Your Tickets")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable UI

struct HeaderBar: View {
    var title: String
    var accent: Color
    var action: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "chevron.backward").font(.headline)
            Spacer()
            Text(title).font(.title3).fontWeight(.bold)
            Spacer()
            if let action { Button(action: action) { Label("Filter", systemImage: "slider.horizontal.3") } }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

struct SectionHeader: View {
    var title: String
    var body: some View {
        Text(title).textCase(.uppercase).font(.headline).fontWeight(.heavy).padding(.horizontal)
    }
}

struct PillButton: View {
    var title: String
    var accent: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).fontWeight(.semibold)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .foregroundStyle(Theme.schoolAccent.luminance > 0.55 ? Color.black : Color.white)
        }
        .buttonStyle(.plain)
        .padding(6)
        .background(accent)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Theme.shadow, radius: 4, x: 0, y: 2)
    }
}

struct CTAButton: View {
    var title: String
    var accent: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.headline).fontWeight(.heavy).frame(maxWidth: .infinity).padding().foregroundStyle(Theme.schoolAccent.luminance > 0.55 ? Color.black : Color.white)
        }
        .background(accent)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .shadow(color: Theme.shadow, radius: 8, x: 0, y: 4)
    }
}

struct BannerButton: View {
    var title: String
    var accent: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.subheadline).fontWeight(.heavy).frame(maxWidth: .infinity).padding().foregroundStyle(Theme.schoolAccent.luminance > 0.55 ? Color.black : Color.white)
        }
        .background(accent)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .opacity(0.9)
        .shadow(color: Theme.shadow, radius: 8, x: 0, y: 4)
    }
}

struct Chip: View {
    var text: String
    var accent: Color
    var label: Color = .primary
    var body: some View {
        Text(text)
            .font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(accent)
            .clipShape(Capsule())
            .foregroundStyle(label)
    }
}

struct TeamLogoPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.gray.opacity(0.15))
            .overlay(Image(systemName: "photo").font(.title2).foregroundStyle(.secondary))
            .frame(width: 84, height: 64)
            .shadow(color: Theme.shadow, radius: 4, x: 0, y: 2)
    }
}

struct EventCard: View {
    var event: Event
    var accent: Color
    var body: some View {
        NavigationLink(destination: EventDetailsView(event: event, accent: accent)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    TeamLogoPlaceholder()
                    Spacer(minLength: 8)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.title).font(.headline)
                        HStack(spacing: 8) {
                            Chip(text: event.isHome ? "HOME" : "AWAY", accent: .black.opacity(0.05), label: .secondary)
                            Chip(text: event.ticketsAvailable ? "AVAILABLE" : "NOT AVAILABLE", accent: event.ticketsAvailable ? Color.green.opacity(0.2) : Color.red.opacity(0.2), label: .secondary)
                        }
                        Text("VS").font(.caption).foregroundStyle(.secondary)
                        Text(event.awaySchool.name).font(.caption2).foregroundStyle(.secondary)
                    }
                }
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text(dateString(event.date)).font(.subheadline).fontWeight(.semibold)
                        Text(timeString(event.date)).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.tertiaryLabel)
                }
            }
            .padding(14)
            .cardStyle()
            .frame(width: 300)
        }
        .buttonStyle(.plain)
    }
}

struct EventRow: View {
    var event: Event
    var accent: Color

    var body: some View {
        NavigationLink(destination: EventDetailsView(event: event, accent: accent)) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(weekdayString(event.date)).font(.caption).foregroundStyle(.secondary)
                        Text(dateString(event.date)).font(.headline)
                        Text(f"{timeString(event.date)} [EST]").font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("BOYS BASEBALL JV/V").font(.headline).textCase(.uppercase)
                        HStack(spacing: 8) {
                            Chip(text: event.isHome ? "HOME" : "AWAY", accent: .black.opacity(0.05), label: .secondary)
                            Chip(text: event.ticketsAvailable ? "AVAILABLE" : "NOT AVAILABLE", accent: (event.ticketsAvailable ? Color.green : Color.red).opacity(0.85), label: .white)
                        }
                        HStack(alignment: .center) {
                            TeamLogoPlaceholder()
                            Text("VS").font(.caption).padding(.horizontal, 8).background(Capsule().fill(.thinMaterial))
                            TeamLogoPlaceholder()
                        }
                        HStack { Text(event.homeSchool.name).font(.caption2); Spacer(); Text(event.awaySchool.name).font(.caption2) }
                    }
                }
                Divider()
                HStack {
                    Chip(text: event.isHome ? "HOME" : "AWAY", accent: accent.opacity(0.85), label: Theme.schoolAccent.luminance > 0.55 ? .black : .white)
                    Chip(text: event.ticketsAvailable ? "AVAILABLE" : "NOT AVAILABLE", accent: (event.ticketsAvailable ? Color.green : Color.red).opacity(0.85), label: .white)
                    Spacer()
                }
            }
            .padding(14)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

struct TicketCard: View {
    var ticket: Ticket
    var accent: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8).fill(.gray.opacity(0.15)).frame(width: 48, height: 48).overlay(Image(systemName: "square.grid.2x2.fill"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(ticket.event.homeSchool.name) VS \(ticket.event.awaySchool.name)").font(.subheadline).fontWeight(.semibold)
                    Text(dateTimeString(ticket.event.date)).font(.caption).foregroundStyle(.secondary)
                    Text("GA x \(ticket.quantity)").font(.caption).fontWeight(.bold)
                }
                Spacer()
            }
        }
        .padding(14)
        .cardStyle()
    }
}

struct ShopCard: View {
    var title: String
    var accent: Color
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.headline).textCase(.uppercase)
                Text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

struct NewsCard: View {
    var accent: Color
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.15)).frame(width: 84, height: 84).overlay(Image(systemName: "person.crop.square"))
            VStack(alignment: .leading, spacing: 6) {
                Text("SAMPLE NEWS TITLE").font(.subheadline).fontWeight(.semibold)
                Text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .cardStyle()
    }
}

struct InfoTile: View {
    var title: String
    var value: String
    var accent: Color
    var imageSystemName: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: imageSystemName ?? "calendar").labelStyle(.titleAndIcon).font(.caption).fontWeight(.bold).textCase(.uppercase)
            Text(value).font(.headline)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct InfoTextField: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon).font(.caption).fontWeight(.bold).textCase(.uppercase)
            Text(value).font(.headline)
        }
        .padding(14)
        .cardStyle()
    }
}

struct InfoMultiline: View {
    var title: String
    var value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).fontWeight(.bold).textCase(.uppercase)
            Text(value).font(.body)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
        }
        .padding(14)
        .cardStyle()
    }
}

struct FilterSheet: View {
    var accent: Color
    @Environment(\.dismiss) private var dismiss
    @State private var homeOnly = true
    @State private var showAvailable = true

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Home Games Only", isOn: $homeOnly)
                Toggle("Tickets Available", isOn: $showAvailable)
                Section("Date") {
                    DatePicker("From", selection: .constant(.now), displayedComponents: [.date])
                    DatePicker("To", selection: .constant(.now.addingTimeInterval(7*24*3600)), displayedComponents: [.date])
                }
            }
            .navigationTitle("Filter")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .tint(accent)
    }
}

// MARK: - Date Helpers

func dateString(_ date: Date) -> String {
    let f = DateFormatter(); f.dateFormat = "EEE, MMM d"; return f.string(from: date).uppercased()
}
func timeString(_ date: Date) -> String { let f = DateFormatter(); f.dateFormat = "h:mm a"; return f.string(from: date) }
func weekdayString(_ date: Date) -> String { let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: date).uppercased() }
func dateTimeString(_ date: Date) -> String { let f = DateFormatter(); f.dateFormat = "h:mm a [EST]"; let t = f.string(from: date); let d = dateString(date); return "\(t)\n\(d)" }
