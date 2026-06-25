# klinika_ai

Adaptive patient intake powered by Flutter GenUI, Firebase AI, and Gemini.

`klinika_ai` is a workshop demo app for Google I/O Extended x Build With AI
Yaounde 2026. It demonstrates Generative UI: instead of returning only text,
Gemini streams A2UI/GenUI instructions that create real Flutter widgets during
the conversation.

The local scenario is patient intake in Cameroon. A patient describes symptoms
in French, English, Camfranglais, or a mix, and the app builds a tailored intake
surface for that patient: triage level, recommended department, related symptom
chips, and clinically relevant follow-up fields.

## Status

- Flutter scaffold: complete
- Android Firebase connection: configured
- Firebase project: `klinika-ai`
- Gemini model: `gemini-2.0-flash`
- Android package: `dev.buildwithai.yaounde.klinika_ai`
- iOS bundle ID: `dev.buildwithai.yaounde.klinikaAi`
- iOS service plist: not currently present in this checkout

## What The App Demonstrates

- A dark, clinical-modern Flutter UI with a Cameroon-inspired green accent
- A one-time onboarding flow stored locally with `shared_preferences`
- A conversational patient intake flow
- A modern tactile input dock with haptic feedback, keyboard dismissal, and
  scroll-to-latest behavior
- Temporary main input hiding while the latest generated UI is waiting for an
  answer
- Read-only generated surfaces after submission to avoid accidental duplicate
  sends
- Non-interactive GenUI care summaries when no more input is needed
- A multilingual animated empty state with typewriter-style guidance
- Gemini streaming responses through `firebase_ai`
- GenUI dynamic surfaces rendered with `SurfaceController`, `Conversation`,
  `Catalog`, and `Surface`
- Custom GenUI catalog items:
  - `TriageBanner`
  - `DepartmentSelector`
  - `SymptomChipGroup`
  - `CareSummary`
  - `ClinicalTextInput`
  - `PainScale`
  - `DurationSelector`
  - `YesNoCheck`
- Core GenUI widgets for generated follow-up forms
- GetX state for session lifecycle and input state
- GoRouter routing for welcome and session screens

## Tech Stack

- Flutter `3.44.3`
- Dart `3.12.2` through the pinned Flutter SDK
- FVM for Flutter version management
- Firebase Core
- Firebase AI for Gemini
- GenUI `0.9.x`
- GetX
- GoRouter
- flutter_animate
- HugeIcons
- shared_preferences

## Project Structure

```text
lib/
  main.dart
  firebase_options.dart
  app/
    app.dart
    router.dart
    theme.dart
  core/
    constants/
      strings.dart
    utils/
      logger.dart
  features/
    intake/
      catalog/
        klinika_catalog.dart
        widgets/
          care_summary.dart
          clinical_text_input.dart
          department_selector.dart
          duration_selector.dart
          pain_scale.dart
          symptom_chip_group.dart
          triage_banner.dart
          yes_no_check.dart
      controllers/
        intake_controller.dart
      views/
        intake_shell.dart
        session_view.dart
        welcome_view.dart
  shared/
    widgets/
      klinika_button.dart
      klinika_text_field.dart
      typing_indicator.dart
assets/
  images/
  lottie/
```

## How The Flow Works

1. `main.dart` initializes Flutter bindings, GenUI logging, and Firebase.
2. `KlinikaApp` starts a `MaterialApp.router`.
3. `router.dart` mounts `IntakeShell` around the intake routes.
4. `IntakeShell` registers `IntakeController` once with GetX.
5. `WelcomeView` shows the onboarding only until the user starts the first
   session, then stores that preference locally.
6. `IntakeController` creates:
   - a `SurfaceController`
   - an `A2uiTransportAdapter`
   - a `Conversation`
   - the custom Klinika catalog
7. When the patient sends symptoms, the controller dismisses the keyboard,
   gives haptic feedback, scrolls the session, and sends the text to Gemini.
8. Gemini streams GenUI/A2UI chunks back.
9. The transport parses those chunks into surface updates.
10. `SessionView` renders each generated surface with GenUI `Surface`.
11. If a generated UI submits an answer, that surface is locked read-only.
12. When Gemini has enough context, it returns a non-interactive GenUI
    `CareSummary` instead of asking another question.

Gemini is initialized lazily when the first message is sent. This keeps the
welcome screen and widget tests from requiring a live Firebase app before the
session is actually used.

## GenUI Catalog

The catalog starts from `BasicCatalogItems.asNoAssetCatalog()` and adds
healthcare-specific interactive items.

### `TriageBanner`

Displays the urgency level and a short explanation.

Expected data:

```json
{
  "severity": "urgent",
  "message": "Consultation urgente recommandee."
}
```

Allowed severity values:

- `urgent`
- `moderate`
- `routine`

### `DepartmentSelector`

Shows the most relevant clinical service for the described symptoms.

Expected data:

```json
{
  "department": "Urgences",
  "reason": "Douleur thoracique intense depuis ce matin."
}
```

### `SymptomChipGroup`

Shows related symptom chips the patient might recognize.

Expected data:

```json
{
  "label": "Symptomes associes",
  "chips": ["Fievre", "Maux de tete", "Fatigue"]
}
```

### `CareSummary`

Shows the final non-interactive handoff surface with clear priority,
recommended service, organized summary blocks, next steps, warnings, and a
short safety disclaimer. This replaces raw Markdown for final responses.

Expected data:

```json
{
  "severity": "moderate",
  "title": "Resume de triage",
  "subtitle": "Les symptomes meritent une consultation sans attendre trop longtemps.",
  "department": "Medecine generale",
  "sections": [
    {
      "heading": "Ce que j ai compris",
      "body": "Fievre depuis 3 jours avec maux de tete.",
      "kind": "summary"
    },
    {
      "heading": "Prochaine etape",
      "body": "Faire verifier les constantes et discuter du traitement avec un soignant.",
      "kind": "nextSteps"
    }
  ],
  "disclaimer": "Cette fiche aide au triage et ne remplace pas un diagnostic medical."
}
```

### `ClinicalTextInput`

Shows a free-text clinical question with a trailing submit button. Pressing the
button or keyboard submit sends a `continue_intake` event back to Gemini.

Expected data:

```json
{
  "label": "Depuis quand exactement?",
  "value": {"path": "/duration_notes"},
  "placeholder": "Ex: depuis hier soir"
}
```

### `PainScale`

Shows a tactile slider for symptom intensity.

Expected data:

```json
{
  "label": "Sur 10, la douleur est a combien?",
  "value": {"path": "/pain_score"},
  "min": 0,
  "max": 10
}
```

### `DurationSelector`

Shows quick duration choices for symptoms.

Expected data:

```json
{
  "label": "Depuis quand?",
  "value": {"path": "/duration"},
  "options": [
    {"label": "Aujourd'hui", "value": "today"},
    {"label": "1-2 jours", "value": "1_2_days"},
    {"label": "Plus de 3 jours", "value": "3_plus_days"}
  ]
}
```

### `YesNoCheck`

Shows a fast yes/no/not-sure clinical check.

Expected data:

```json
{
  "label": "Tu as deja verifie la temperature?",
  "value": {"path": "/temperature_checked"},
  "yesLabel": "Oui",
  "noLabel": "Non",
  "unknownLabel": "Pas encore"
}
```

## Firebase Setup

The project is configured for Firebase project:

```text
klinika-ai
```

The Android app is connected through:

```text
android/app/google-services.json
lib/firebase_options.dart
firebase.json
```

The Android Gradle Google Services plugin is enabled in:

```text
android/settings.gradle.kts
android/app/build.gradle.kts
```

For live Gemini responses, make sure Vertex AI in Firebase is enabled in the
Firebase Console for `klinika-ai`.

If Firebase needs to be regenerated, run:

```powershell
flutterfire configure --project=klinika-ai --platforms=android,ios
```

Use these identifiers:

```text
Android package: dev.buildwithai.yaounde.klinika_ai
iOS bundle ID: dev.buildwithai.yaounde.klinikaAi
```

For iOS, confirm this file exists before running on an iOS device:

```text
ios/Runner/GoogleService-Info.plist
```

## Prerequisites

Install or verify:

```powershell
fvm --version
firebase --version
flutterfire --version
```

This app is pinned to Flutter `3.44.3`.

```powershell
fvm install 3.44.3
fvm use 3.44.3
```

If `fvm flutter` does not resolve correctly on Windows, the pinned SDK can also
be called directly:

```powershell
& 'C:\Users\%USER%\fvm\versions\3.44.3\bin\flutter.bat' --version
```

## Install Dependencies

```powershell
fvm flutter pub get
```

Or with the direct SDK path:

```powershell
& 'C:\Users\%USER%\fvm\versions\3.44.3\bin\flutter.bat' pub get
```

## Run The App

Android device or emulator:

```powershell
fvm flutter run
```

Build debug APK:

```powershell
fvm flutter build apk --debug
```

Build release APK:

```powershell
fvm flutter build apk --release
```

APK outputs are written under:

```text
build/app/outputs/flutter-apk/
```

## Verification

Run:

```powershell
fvm flutter analyze
fvm flutter test
```

The widget test verifies that the welcome screen renders.

If Flutter commands hang on Windows, check for long-running Dart, Java, or
Gradle processes from a previous build:

```powershell
Get-Process | Where-Object { $_.ProcessName -match 'dart|flutter|gradle|java' }
```

Do not stop those processes while an APK build is still running.

## Workshop Demo Script

Use these prompts during the live demo.

### 1. Fever, French

```text
J'ai de la fievre depuis 3 jours et des maux de tete.
```

Expected behavior:

- moderate or urgent triage banner
- general medicine department
- related symptom chips
- follow-up fields for duration and intensity, grouped as 2-3 focused
  questions when more context is needed
- final `CareSummary` when enough information has been collected

### 2. Child Rash, Camfranglais

```text
My pikin get rash for body since yesterday, na fever dey too.
```

Expected behavior:

- pediatric case detection
- pediatrics department
- age-related follow-up field
- related rash and fever chips
- final pediatric `CareSummary` with next steps

### 3. Chest Pain, Urgent

```text
J'ai une douleur forte a la poitrine depuis ce matin.
```

Expected behavior:

- urgent red triage banner
- emergency department
- minimal critical follow-up fields
- no long static intake form
- final urgent `CareSummary` if the urgent picture is already clear

The point of the demo: same app, same code, different UI each time.

## Interactive UI Trigger Prompts

Use these during testing to nudge Gemini toward specific catalog widgets.

### Clinical Text Input

```text
Je tousse beaucoup depuis ce matin, pose-moi juste les questions importantes une par une.
```

Expected UI: `ClinicalTextInput` with a trailing submit icon and a Continue
button fallback.

### Pain Scale

```text
J'ai une douleur forte au ventre, environ 8 sur 10, depuis ce matin.
```

Expected UI: `PainScale`, triage banner, and department recommendation.

### Duration Selector

```text
My pikin get fever since yesterday night and rash dey come out.
```

Expected UI: `DurationSelector`, pediatric department, related rash/fever chips.

### Yes/No Check

```text
Je crache un peu de sang quand je tousse, mais je ne sais pas si j'ai la fievre.
```

Expected UI: `YesNoCheck` for fever, blood, breathing difficulty, or other
clinically relevant checks.

### Choice Picker

```text
I feel dizzy with headache and blurred vision.
```

Expected UI: `ChoicePicker` for associated symptoms and warning signs.

### Final Care Summary

```text
J'ai eu de la fievre pendant 3 jours, mal a la tete, pas de douleur thoracique, et je bois encore normalement.
```

Expected UI: non-interactive `CareSummary` with priority, recommended service,
summary blocks, next steps, and disclaimer.

## Stress Test Prompts

Use these to test longer, messier patient stories with mixed language, multiple
symptoms, red flags, and enough ambiguity to force Gemini to choose between
asking 2-3 focused questions or finalizing with a `CareSummary`.

### 1. Mixed Symptoms, Camfranglais, Possible Urgency

```text
Depuis hier soir my chest dey pain small-small but parfois e tight comme pression, surtout quand I climb stairs. J'ai aussi un peu de vertige, sueur froide cette nuit, and my left arm felt heavy for like 10 minutes. Je ne sais pas si c'est stress because I had palpitations before, mais aujourd'hui je suis fatigue et j'ai un peu de nausea. No cough, no fever that I know.
```

Expected behavior:

- urgent or high-priority moderate triage
- emergency or cardiology-related recommendation
- 2-3 focused follow-up fields at most if Gemini needs missing details
- final `CareSummary` with warning signs and urgent next steps

### 2. Pediatric Case, Fever, Rash, Medication Context

```text
Mon enfant de 4 ans a la fievre depuis 3 jours, rash for body started yesterday, il gratte beaucoup, and today he vomited twice. On lui a donne paracetamol but temperature comes back after some hours. Il boit un peu but less than usual, urine small today, no convulsions, but he looks tired. The rash is mostly on chest and face, not sure if palms/feet. What should we do?
```

Expected behavior:

- pediatric triage with dehydration/rash awareness
- symptom chips for fever, rash, vomiting, hydration, tiredness
- grouped follow-up questions about temperature, rash spread, hydration, and danger signs
- final `CareSummary` with pediatric next steps and safety disclaimer

## Troubleshooting

### The app opens but Gemini does not respond

Check:

- Firebase project is `klinika-ai`
- Vertex AI in Firebase is enabled
- device has internet access
- `Firebase.initializeApp` succeeds on startup
- `android/app/google-services.json` matches the current Firebase project

### Firebase says no default app exists

Confirm `main.dart` initializes Firebase before `runApp`:

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### Android build cannot find Firebase config

Confirm:

```text
android/app/google-services.json
android/settings.gradle.kts
android/app/build.gradle.kts
```

The Gradle files should include the Google Services plugin added by FlutterFire.

### iOS fails to connect to Firebase

Regenerate Firebase config with iOS included and verify:

```text
ios/Runner/GoogleService-Info.plist
```

### Generated UI is blank

Gemini must produce valid A2UI messages for interactive forms and final
summaries. Check debug logs for GenUI parsing, missing `version: "v0.9"`, or
missing `root` component warnings.

### The same form appears repeatedly

The system prompt instructs Gemini to adapt every response. If repetition occurs
during a demo, reset the session and use a more specific patient prompt.

## Notes For Presenters

- Keep the first prompt short and symptom-focused.
- Mention that GenUI is architecture, not magic.
- Show that the custom catalog gives Gemini domain-specific building blocks.
- Point out that static forms are not removed; they are generated only when
  clinically relevant.
- For safety, this is a triage/intake demo, not medical diagnosis software.

## Repository And Contributions

GitHub repository:

```text
https://github.com/Joel-Fah/klinika-ai
```

Clone:

```powershell
git clone https://github.com/Joel-Fah/klinika-ai.git
cd klinika-ai
fvm flutter pub get
```

Recommended contribution flow:

1. Create a branch from `main`.
2. Keep changes focused on one feature, fix, or documentation update.
3. Run `fvm flutter analyze` and `fvm flutter test`.
4. Open a pull request with:
   - a short summary
   - screenshots or screen recordings for UI changes
   - notes about Firebase or platform configuration changes

Do not commit secrets, service account files, private keys, or production-only
Firebase credentials. Client Firebase config files such as
`android/app/google-services.json` are expected for this demo app, but access to
the Firebase project should still be restricted from the Firebase Console.

## Security And Configuration Notes

- Firebase config files identify the Firebase app and are required for client
  builds.
- Do not place service account JSON files, private keys, or server credentials
  in this repository.
- Restrict Firebase APIs and project access in the Firebase Console before
  using this outside a workshop/demo environment.

## License

Workshop demo project. Add a license before publishing or distributing outside
the event context.
