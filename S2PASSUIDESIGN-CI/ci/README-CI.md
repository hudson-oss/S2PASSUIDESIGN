# CI to build an iPhone-installable `.ipa`

This workflow archives and exports an iOS `.ipa` you can install on devices (Ad Hoc or Development). It can also be switched to TestFlight.

## 1) Add files to your repo
Copy the contents of this `S2PASSUIDESIGN-CI` bundle into the root of your repo:
- `.github/workflows/ios-build.yml`
- `ci/exportOptionsAdHoc.plist`
- `ci/README-CI.md` (optional)

## 2) Prepare Apple signing (Ad Hoc)
Create a **Distribution** certificate and an **Ad Hoc provisioning profile** for your bundle id.

1. Bundle ID (example): `com.example.s2passuidesign`
2. Add device UDIDs you want to install on to the Ad Hoc profile.
3. Export your certificate as **P12** and note the password.
4. Download the **.mobileprovision** for the Ad Hoc profile.

Convert both files to base64 and save as GitHub secrets:

```bash
base64 -i Distribution.p12 | pbcopy
base64 -i AdHoc.mobileprovision | pbcopy
```

GitHub → **Settings → Secrets and variables → Actions → New repository secret**

- `CERT_P12` – contents of the base64 P12
- `CERT_PASSWORD` – password you used for the P12
- `PROVISIONING_PROFILE` – contents of the base64 .mobileprovision
- `BUNDLE_ID` – e.g., `com.example.s2passuidesign`

*(Optional for TestFlight)*
- `APPSTORE_CONNECT_API_KEY_JSON` – JSON for a key (Issuer/Key ID in ASC)
- `ASC_ISSUER_ID` – Issuer ID
- `ASC_KEY_ID` – Key ID

## 3) Kick off a build
GitHub → **Actions → iOS – Build & Distribute → Run workflow**
- `scheme`: `S2PassUIDesignApp` (or your scheme)
- `configuration`: `Release`
- `export_method`: `ad-hoc` (or `development` if using a Dev profile)

The job will produce an artifact like:
`S2PASSUIDESIGN_<run_id>_ad-hoc.ipa`

Download and install on-device using Apple Configurator, Xcode Devices, or a service like Diawi. You’ll need the device UDID added to the profile.

## Notes
- The workflow auto-detects whether your repo has an `.xcodeproj` or `.xcworkspace` at the root.
- Make sure your scheme is **shared** in Xcode (Product → Scheme → Manage Schemes → check “Shared”).

## TestFlight (optional)
Switch the `testflight` job `if: ${{ false }}` to `if: ${{ true }}` and supply the App Store Connect API key secrets. That job will build and upload to TestFlight using fastlane.
