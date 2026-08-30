# Movie App — Flutter Graduation Project

Movie browsing app. Data from the [YTS API](https://yts.mx/api); auth, Google sign-in
and the watchlist from Firebase.
Design: [Figma — Movies](https://www.figma.com/design/yIeirbhqtxNGkAgThx8HnX/Movies--Copy-?node-id=29-430&m=dev)

---

## 1. Get running (do this first, before you touch any task)

```bash
git clone <repo-url>
cd movie_app
flutter pub get
flutter run
```

The app builds and runs today — every Sprint 1 screen is a placeholder saying
`TODO`. Your task is to replace your own placeholder.

> **Firebase is not wired yet.** The lead runs `flutterfire configure`, which
> generates `lib/firebase_options.dart`, and then uncomments the two lines in
> `lib/main.dart`. Until that lands the app still runs — only the auth calls
> fail. Don't run `flutterfire configure` yourself; it would overwrite the
> shared config.

---

## 2. The rules (these affect our grade — don't deviate)

1. **Bloc only.** `flutter_bloc`, full `Bloc` classes with Event → State. Not
   `Cubit`, not `setState` for screen state, and **not Provider** — you'll see
   `provider` in `pubspec.lock` because `flutter_bloc` depends on it
   internally. That is not permission to use it.
2. **Responsive.** `flutter_screenutil` handles sizing — every number is
   suffixed `.w` (width), `.h` (height), `.r` (radius) or `.sp` (font). A bare
   `16` in a widget is a bug: it will look right on your phone and wrong on
   everyone else's. There is deliberately **no `AppDimens` file** — screenutil
   is the responsive layer, and a second constants file for spacing just
   duplicates it.
3. **Zero hardcoded strings or colours.** Strings live in
   `core/constants/app_strings.dart`, everything visual lives in
   `core/theme/`. A literal `Color(0xFF...)` or `'Login'` inside a widget will
   be sent back in review. Design-system values that define the *look* —
   `radius`, `controlHeight`, `designSize` — are on `AppTheme`; per-screen
   spacing is just `24.w` at the call site.
4. **Dio, not `http`,** for every API call (Sprint 2).
5. **Never push to `main`.** Ever. See §5.
6. **Never delete a branch,** even after it's merged.
7. **No function that returns a widget.** `Widget buildHeader()` is wrong —
   make it a widget class in a `widgets/` folder.
8. **One or two classes per file.**

---

## 3. Project structure

```
lib/
  main.dart                      app entry — DI + (soon) Firebase init
  app.dart                       MaterialApp + ScreenUtilInit + theme + routes
  core/                          shared by everything — do not put feature code here
    constants/  app_strings.dart  app_assets.dart
    theme/      app_colors.dart  app_text_styles.dart  app_theme.dart
                ↑ all visual values live here: palette, type scale, ThemeData,
                  plus designSize / radius / controlHeight
    di/         injector.dart          get_it registrations
    routes/     app_router.dart  app_route_names.dart
    widgets/    primary_button.dart  app_text_field.dart
                loading_view.dart  error_view.dart  empty_view.dart
  features/
    <feature>/
      data/         datasources/   talks to Firebase / the API
                    repositories/  implements the domain contract
      domain/       entities/      plain Dart models
                    repositories/  abstract contract the UI codes against
      presentation/ bloc/          <name>_bloc.dart  _event.dart  _state.dart
                    screens/       <name>_screen.dart
                    widgets/       pieces used only by this feature
```

Rule of thumb: **if two features need it, it belongs in `core/`.** If only one
screen needs it, it stays in that feature's `widgets/`.

### Sprint 1 files, and who owns each one

Everything below already exists. Files marked ✅ are done — read them, use
them, don't rewrite them. Files marked 🔨 are placeholders waiting for their
owner.

```
lib/
  main.dart                                              ✅ lead
  app.dart                                               ✅ lead
  core/**                                                ✅ lead   (all of it)
  features/
    splash/presentation/screens/splash_screen.dart       🔨 Splash task
    onboarding/presentation/
      screens/onboarding_screen.dart                     🔨 Onboarding task
      widgets/onboarding_slide.dart                      🔨 Onboarding task
      widgets/onboarding_page_indicator.dart             🔨 Onboarding task
    auth/
      domain/entities/app_user.dart                      ✅ lead
      domain/repositories/auth_repository.dart           ✅ lead  ⚠️ shared contract
      data/datasources/firebase_auth_datasource.dart     🔨 shared — 3 owners
      data/repositories/auth_repository_impl.dart        ✅ lead  ⚠️ shared
      presentation/
        bloc/login/*.dart                                🔨 Login task
        bloc/register/*.dart                             🔨 Register task
        bloc/forgot_password/*.dart                      🔨 Reset task
        screens/login_screen.dart                        🔨 Login task
        screens/register_screen.dart                     🔨 Register task
        screens/forgot_password_screen.dart              🔨 Reset task
        widgets/google_sign_in_button.dart               🔨 Login task
```

**Three files are shared** — more than one branch touches them:
`firebase_auth_datasource.dart`, `injector.dart`, `app_router.dart`. Each has a
comment saying so. Add only your own method / registration / `case`, leave
everyone else's lines alone, and pull from `development` often. See §6.

---

## 4. Sprint 1 tasks

Each task is one branch, one PR. Open the file — every placeholder has the
numbered steps for its own task in a comment at the top.

### Task 1 — Splash (UI only) · branch `dev/splash-<yourname>`

- [ ] Background `AppColors.background`, centred logo (Figma `29:431`)
- [ ] Bottom gold lockup + `AppStrings.supervisedBy`
- [ ] Export the images from Figma into `assets/images/`, register the folder in
      `pubspec.yaml`, reference them via `AppAssets`
- [ ] After ~3s `pushReplacementNamed` → `AppRouteNames.onboarding`
- [ ] Cancel the timer in `dispose` (a fast back-press crashes otherwise)
- [ ] All sizes via `.w` / `.h` / `.sp`

### Task 2 — Onboarding (UI only) · branch `dev/onboarding-<yourname>`

- [ ] `PageView` over the six frames (`30:447`, `38:75`, `38:149`, `38:172`,
      `38:188`, `39:294`)
- [ ] **One** `OnboardingSlide` widget fed by a list of data — not six
      near-identical widgets
- [ ] `OnboardingPageIndicator` for the dots
- [ ] Next / Back; last page → `AppRouteNames.login` via
      `pushReplacementNamed`
- [ ] Dispose the `PageController`

> **Splash + Onboarding work together.** They're separate folders with no
> shared files, so build them in parallel — the only overlap is each adding one
> `case` to `app_router.dart`. Agree between the two of you who pushes first;
> whoever is second pulls `development` before opening their PR. If you'd
> rather pair-program them, that's fine too — there's no logic here, so the
> risk either way is low.

### Task 3 — Login (UI + logic) · branch `dev/login-<yourname>`

- [ ] `signInWithEmail` + `signInWithGoogle` in `firebase_auth_datasource.dart`
- [ ] Translate the Firebase error code into a readable sentence **inside the
      data source** — `user-not-found`, `wrong-password`,
      `account-exists-with-different-credential`. The Bloc must never see a raw
      code
- [ ] Google cancel returns `null`, never throws — closing the picker is not an
      error and must not show a red snackbar
- [ ] Fill in `LoginBloc`'s two handlers, register it in `injector.dart`
- [ ] Build the screen (Figma `44:444`) with `AppTextField` + `PrimaryButton`
- [ ] `Form` + validators; `BlocConsumer` — listener navigates / shows errors,
      builder feeds `isLoading` into the button
- [ ] `pushNamedAndRemoveUntil` on success so Back can't return to login
- [ ] Dispose both controllers

### Task 4 — Register (UI + logic) · branch `dev/register-<yourname>`

- [ ] `createAccount` in `firebase_auth_datasource.dart`
- [ ] `updateProfile(displayName: name)` right after sign-up, or the name is
      lost
- [ ] Translate `weak-password` and `email-already-in-use`
- [ ] Fill in `RegisterBloc`, register it in `injector.dart`
- [ ] Build the screen (Figma `44:670`): name, email, password, confirm
      password, phone, avatar strip
- [ ] Confirm-password matching is a `Form` validator, **not** Bloc logic
- [ ] Dispose every controller

### Task 5 — Reset Password (UI + logic) · branch `dev/reset-password-<yourname>`

- [ ] `sendPasswordResetEmail` in `firebase_auth_datasource.dart`
- [ ] Fill in `ForgotPasswordBloc`, register it in `injector.dart`
- [ ] Build the screen (Figma `47:936`): back arrow + title, illustration,
      email field, "Verify Email" button
- [ ] On success show the confirmation **before** popping — the user has to go
      read their inbox
- [ ] Dispose the controller

### Definition of Done (all five tasks)

- [ ] `flutter analyze` → **No issues found** (it is clean right now; any new
      warning is yours)
- [ ] `flutter test` passes
- [ ] Screen matches its Figma node
- [ ] Bloc covers loading / success / failure — no missing branch
- [ ] Zero hardcoded strings, colours, dimensions
- [ ] PR opened against `development`

---

## 5. Git — branches, and why you must never push to `main`

```
main            ← submission-ready. NOBODY pushes here. Ever.
  ↑ (one reviewed PR, together on a call, every Friday)
development     ← everything integrates here
  ↑ (your PR)
dev/<task>-<yourname>
```

**Branch naming:** `dev/<task>-<yourname>` — e.g. `dev/login-sara`,
`dev/splash-khaled`. One branch per task, cut fresh from `development`.

```bash
git checkout development
git pull origin development
git checkout -b dev/login-sara
```

When you're done:

```bash
git push -u origin dev/login-sara
```

Then open a PR into `development` and tell the lead. **The lead does the
merging** — don't merge your own PR.

**Never delete a branch,** even after it's merged. Not one. This is graded.

### Commit messages

`type(scope): what changed` — `feat(login): add firebase email sign-in`,
`fix(splash): cancel timer on dispose`.

**If you touch `pubspec.yaml`, say so in the commit body:**

```
feat(login): add google sign-in

DEPENDENCY: added google_sign_in ^7 — run `flutter pub get` after pulling.
Android also needs the SHA-1 in Firebase Console; talk to me before you pull.
```

Same callout for native-only changes (SHA-1, `google-services.json`,
`Info.plist`) even with no `pubspec.yaml` diff — `flutter pub get` alone won't
fix a missing native step, and your teammate's build will break with no clue
why.

---

## 6. How we avoid merge conflicts

Conflicts are mostly prevented by *where* you write code, not by fixing them
afterwards.

1. **Stay in your own folder.** Almost every Sprint 1 file has exactly one
   owner. If you find yourself editing someone else's screen, stop and ask.
2. **Three files are shared** — `firebase_auth_datasource.dart`,
   `injector.dart`, `app_router.dart`. Add only your own method / registration
   / `case`. Don't reformat, reorder, or "tidy" the rest of the file: that
   turns a clean 1-line addition into a conflict across the whole file.
3. **Don't change `auth_repository.dart`.** Three branches implement against it
   at once. Adding a new method is fine; editing an existing signature breaks
   two other people. Tell the team first.
4. **Pull `development` daily**, even mid-task:
   ```bash
   git checkout development && git pull origin development
   git checkout dev/login-sara && git merge development
   ```
   A conflict found on day 2 is a two-minute fix. The same conflict found on
   day 6 is an evening.
5. **Small PRs, opened early.** One task per PR. A branch that lives a week is
   how conflicts get big.
6. **Don't commit generated files** — `.dart_tool/`, `build/`, `.idea/` are
   already in `.gitignore`. Don't force-add them; they conflict constantly and
   are pure noise.
7. **When a conflict does happen, the whole team resolves it together on a
   call** — nobody resolves someone else's code alone. That's a project rule,
   not a preference.

---

## 7. Working with AI (so five people's code reads as one codebase)

We all use AI assistants. Without a shared brief, five sessions invent five
architectures. Paste this when you start your task:

> I'm building the `<task name>` task in this Flutter movie app. Read
> `README.md` first — especially the rules and the project structure. Follow
> the existing patterns exactly: `flutter_bloc` with full Bloc classes
> (Event → State), `get_it` for DI, `flutter_screenutil` for every size, and
> **no hardcoded strings, colours or dimensions** — they go in
> `core/constants/` and `core/theme/`. Reuse `PrimaryButton`, `AppTextField`,
> `LoadingView`, `ErrorView` from `core/widgets/` instead of writing new ones.
> Never write a function that returns a widget — make it a widget class. Match
> the Figma node in the file's header comment. Only touch the files that belong
> to my task. Stop when the screen is done so I can review it.

The lead is preparing a fuller AI rules doc; it gets linked here once it
exists.

---

## 8. Sprint 2 preview (don't start these yet)

Home, Movie Details, Search, Browse, Profile, Update Profile — plus the YTS
API layer through Dio, the Firestore watchlist, and local watch history.
`dio` is already in `pubspec.yaml` so we don't have to churn dependencies
mid-sprint.

---

## 9. How to develop with this pattern

The architecture is **feature-first + Bloc + repository**. Four layers, and
data only ever flows in one direction:

```
   Screen (widgets)              knows: Bloc, core/widgets
      │  adds an Event                  never: Firebase, Dio, http
      ▼
   Bloc                          knows: the abstract repository
      │  emits a State                  never: Flutter widgets, Firebase
      ▼
   Repository (abstract)         the contract — pure Dart, no packages
      │
      ▼
   RepositoryImpl → DataSource   knows: Firebase / Dio / SharedPreferences
                                       the only layer allowed to
```

**The test:** open any file in `presentation/` and search for `firebase` or
`dio`. If you find one, the layering is broken. The screen asks the Bloc; the
Bloc asks the contract; only `data/` knows what's behind it.

**Why bother, on a 3-week student project?** Because five people work in
parallel. Once `AuthRepository` is agreed, the person building the Login
*screen* and the person building the Firebase *call* can work at the same time
without waiting for each other — they meet at the contract. It's also why your
Bloc is testable without a network.

### Adding a feature, step by step

Say you're adding "Search" in Sprint 2:

1. **Entity first** — `features/search/domain/entities/`. Plain Dart, no
   packages. What does a search result *look* like?
2. **Contract** — `domain/repositories/search_repository.dart`, an `abstract
   class` with the methods the UI needs. Nothing about Dio here.
3. **Implementation** — `data/datasources/` does the actual HTTP call,
   `data/repositories/` implements the contract using it. Errors get
   translated into readable sentences *here*, so no layer above ever sees a
   status code.
4. **Bloc** — `presentation/bloc/search/` with the three files:
   `_event.dart` (what the user did), `_state.dart` (what the screen shows),
   `_bloc.dart` (maps one to the other). Cover **loading, success, failure and
   empty** — "no results" is not an error and must look different.
5. **Register** in `core/di/injector.dart`: repository as
   `registerLazySingleton`, Bloc as `registerFactory`.
6. **Screen** — `presentation/screens/`, wrapped in a `BlocProvider`, built
   with `BlocBuilder` / `BlocConsumer`. Reuse `core/widgets/`.
7. **Route** — add one `case` to `app_router.dart`.

### Rules that keep it readable

- **Never write a function that returns a widget.** `Widget _buildCard()` is
  wrong — make it a class in `widgets/`. Flutter can't skip rebuilding a
  method, so this is a performance rule as much as a style one.
- **One or two classes per file.** A third means a new file.
- **A widget takes data and callbacks — never a Bloc or a repository.** That's
  what makes it reusable and previewable.
- **`context.read<T>()` inside callbacks, `context.watch<T>()` / `BlocBuilder`
  to rebuild.** Using `watch` in an `onPressed` is a common cause of "why does
  this rebuild forever".
- **Dispose every controller** you create (`TextEditingController`,
  `PageController`, `AnimationController`).
- **Comments explain _why_, not _what_.** Delete any comment that restates the
  code.

---

## 10. Tooling — running this whole project on free plans

You do not need to pay for anything. Roughly 20 minutes of setup.

### 10.1 Figma — free Professional via the Education plan

The design file needs **Dev Mode** to read real colours, spacing and fonts out
of Figma instead of eyeballing a screenshot. Dev Mode is a paid feature — but
Figma's Education plan gives verified students the full Professional feature
set for free, valid ~2 years for higher education.

1. Go to Figma's education page and apply with your student proof (university
   email, enrollment letter, or student ID).
2. Once verified, **you must upgrade a team to Education** — verification alone
   does nothing. Open your team → Upgrade → pick the free Education plan. This
   is the step people miss when they say "I'm verified but Dev Mode is still
   locked".
3. Make sure your seat in that team is **Dev or Full**, not View. Seat type is
   what gates MCP access (a View seat gets ~6 calls a *month*).

### 10.2 Connect Figma to your editor via MCP

MCP (Model Context Protocol) lets the AI read the actual Figma file — exact
hex values, spacing, node structure — rather than guessing from an image. This
is how the theme in this repo was built.

**Remote server (recommended, works anywhere):**

```
https://mcp.figma.com/mcp
```

**Local server (Figma desktop app, reads your current selection):**
Figma desktop → menu → Preferences → **Enable Dev Mode MCP Server**. It serves
on `127.0.0.1:3845`.

Rate limits on a Dev/Full seat are roughly **200 calls/day, 10–15/minute** —
generous, but not unlimited, which is why §10.4 matters.

### 10.3 Google Antigravity — free AI coding

Antigravity is Google's agentic IDE (a VS Code fork). The Individual plan is
**$0** and includes frontier models with weekly quotas — enough for a student
project if you don't waste calls.

Add the Figma MCP server one of two ways:

- **MCP Store** — open the agent side panel → dropdown at the top → *MCP
  Servers* → browse and install; or
- **Raw config** — same menu → *Manage MCP Servers* → *View raw config*, which
  opens `~/.gemini/config/mcp_config.json`:

```json
{
  "mcpServers": {
    "figma": {
      "serverUrl": "https://mcp.figma.com/mcp"
    }
  }
}
```

Restart the editor, then confirm the Figma tools show up in the agent panel
before you start a task.

> Free-tier quotas and prices for these tools change often — check the current
> terms rather than trusting this file. Keep secrets out of `mcp_config.json`:
> reference them as `${VAR_NAME}` environment variables.

### 10.4 Making free-tier tokens last

Free quotas run out mid-task if you're careless. What actually helps:

1. **Don't paste whole files.** Give the path and the function name; the agent
   can open what it needs.
2. **Ask for a small Figma node, not a whole screen.** Pull the button
   (`44:619`), not the entire Login frame — one frame can cost several calls
   and flood the context with data you won't use.
3. **Never re-fetch the same node twice.** If a colour is already in
   `AppColors`, use it. The palette is done — nobody needs to hit Figma again
   for `#F6BD00`.
4. **One task per conversation.** Start a fresh chat for a new task instead of
   dragging a long history along; every message re-sends everything above it,
   so a long thread gets expensive fast.
5. **Read the file header first.** Every placeholder here already lists its
   steps and Figma node — that's context you get for free, without spending a
   call to rediscover it.
6. **Prefer `flutter analyze` over asking the AI to find your bug.** It's
   instant, free, and usually right.
7. **Use the cheaper/faster model for boilerplate** and save the strong one
   for the parts you're genuinely stuck on.

**Sources:** [Figma pricing FAQ](https://www.figma.com/pricing-faq/) ·
[Figma MCP guide](https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server) ·
[MCP rate limits & access](https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/) ·
[Antigravity MCP docs](https://antigravity.google/docs/ide/mcp/) ·
[Antigravity plans](https://antigravity.google/blog/changes-to-antigravity-plans)
