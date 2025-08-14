# S2PASSUIDESIGN — iOS SwiftUI UI Demo

SwiftUI prototype of the S2 Pass ticketing app UI. This repo is **UI-only** (no networking or auth) and mirrors the design in the attached PDF (Homepage, Events, Event Details, Your Tickets) with brand‑color customization and contrast‑aware chips/buttons.

## Quick Start (Xcode 15+, iOS 17+)

1. Open Xcode → File → New → Project… → iOS App (SwiftUI).
2. Name it **S2PASSUIDESIGN**.
3. Quit Xcode.
4. Copy the contents of this repo into the Xcode project folder, replacing `ContentView.swift` with `S2PASSUIDesignApp.swift` (or add it and set this file's `@main` app).
5. Reopen the project, run on an iPhone 15 Pro simulator.

> Why not ship the `.xcodeproj`? Xcode generates project files that are environment‑specific. This repo keeps the sources/asssets clean. When you create a new project locally, Xcode will generate the project metadata for you.

## Brand Tokens
Update colors in `Theme` at the top of `S2PASSUIDesignApp.swift`. You can later replace these with official tokens from Frontify.

## Repo Layout
```
S2PASSUIDESIGN/
├─ README.md
├─ LICENSE
├─ .gitignore
└─ S2PASSUIDesignApp/
   ├─ S2PASSUIDesignApp.swift        # Full SwiftUI demo (tabs, lists, details)
   └─ Assets.xcassets/
      └─ AppIcon.appiconset/         # Placeholder App Icon (supply your own later)
```

## Notes
- Contrast-aware labels on accent buttons match the design requirement.
- Sections/labels and CTAs mirror the mock (e.g., “VIEW ALL”, “GO TO”, “OUR BANNER SPONSOR?”, “PURCHASE TICKETS”).

## License
MIT
