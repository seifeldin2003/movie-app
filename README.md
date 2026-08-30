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
2. **Responsive.** Every size goes through `flutter_screenutil` — `.w` `.h`
   `.r` `.sp`. No raw pixel numbers in a widget.
3. **Zero hardcoded strings, colours, or dimensions.** They live in
   `core/constants/` and `core/theme/`. A literal `Color(0xFF...)` or
   `'Login'` inside a widget will be sent back in review.
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
    constants/  app_strings.dart  app_assets.dart  app_dimens.dart
    theme/      app_colors.dart  app_text_styles.dart  app_theme.dart
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
