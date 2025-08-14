# CI to build an iPhone-installable `.ipa` — FIXED

This updated workflow adds:
- Secret validation (clear errors if a secret is missing)
- Robust provisioning profile decode (with helpful failure)
- Auto wiring of `provisioningProfiles` to your `BUNDLE_ID`
- Project/workspace discovery in subfolders (depth 3)
- Working-directory fix for archive path

## Upload these files to your repo:
- `.github/workflows/ios-build.yml`  (replace existing)
- `ci/exportOptionsAdHoc.plist`      (replace existing)
- `ci/README-CI.md`                  (optional, replace existing)

## Required GitHub Secrets
- `CERT_P12` — base64 of your **.p12** (Distribution or Development)
- `CERT_PASSWORD` — password you used exporting the .p12
- `PROVISIONING_PROFILE` — base64 of your **.mobileprovision** (Ad Hoc or Development), with device UDIDs added
- `BUNDLE_ID` — must match the provisioning profile

## Run
Actions → “iOS – Build & Distribute” → Run workflow with:
- scheme: `S2PassUIDesignApp`
- configuration: `Release`
- export_method: `ad-hoc` (or `development`)

**Important:** Commit your Xcode project (.xcodeproj or .xcworkspace) to the repo.
