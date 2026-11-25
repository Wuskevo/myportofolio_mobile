# MyPortfolio Mobile

[![CI](https://github.com/Wuskevo/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/Wuskevo/myportofolio_mobile/actions/workflows/main.yaml)

Flutter client for the MyPortfolio Django REST Framework backend.

## Backend

The Django backend source code is in the
[Wuskevo/myportofolio repository](https://github.com/Wuskevo/myportofolio/).
The app uses the `/api/v1/` endpoints for projects, experiences, credentials,
and token authentication.

## Setup

Install Flutter, ensure the Django backend is running and reachable from your
target device, then fetch dependencies and generate the JSON model code:

```shell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Set `API_BASE_URL` to the backend's base URL (the host root, without `/api/v1`).
For an Android emulator with Django running on the development machine:

```shell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

For Flutter web running on the same machine as Django:

```shell
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

For a deployed backend, replace the local address with its publicly reachable
base URL.

## CI

GitHub Actions runs the Flutter workflow and builds a release APK. The
`build_apk` job uploads the APK as the `app-release-apk` artifact.

# Reflection & AI Disclosure

## Assignment 7

### AI Disclosure

Besides helping me answer the Reflection Questions, no AI was used to write code since there is few to no additions from the tutorial for this assignment.

### 1. What is a widget tree, and how do parent-child relationships work?

In Flutter, everything on screen is a **widget**, and widgets are nested inside
each other to form a **widget tree**. The definitions of **parents** and **children** don't differ from trees in general. Currently the home screen widget tree looks
like this:

```
MaterialApp
└── MyHomePage
    └── Scaffold
        ├── AppBar
        └── Padding
            └── Column
                ├── Row
                │   └── InfoCard x3
                ├── SizedBox
                └── Center
                    └── Column
                        ├── Padding → Text
                        └── GridView.count
                            └── ItemCard x3
```

(widget tree visualization provided by Claude)

Rules of the parent-child relationship:

- A parent decides **where and how big** its children are (e.g. `Column`
  stacks children vertically, `Row` horizontally, `GridView` in a grid).
- Constraints flow **down** (the parent tells a child the min/max size it may
  use), and sizes flow **back up** (the child reports the size it picked).
- Some widgets take one child (`child:`, e.g. `Padding`, `Center`), others take
  several (`children: [...]`, e.g. `Column`, `Row`).
- When something changes, Flutter rebuilds the affected part of the tree.
  This is similar to Godot's scene tree: `Column`, `Row` and `GridView` behave
  like container nodes (`VBoxContainer`, `HBoxContainer`, `GridContainer`) that
  arrange their children. The main difference is that a Godot node is a
  long-lived object you modify in place, while a Flutter widget is a lightweight,
  immutable description that is recreated each time `build()` runs. Flutter
  compares the new description with the old one and only updates what changed.

---

### 2. Widgets used in this project and their functions

| Widget                | Function                                                      | Closest Godot equivalent                      |
| --------------------- | ------------------------------------------------------------- | --------------------------------------------- |
| `MyApp` (custom)      | Root widget; sets the theme and the home screen               | Main scene / project setup                    |
| `MaterialApp`         | App-wide configuration: theme, title, home screen, navigation | Project settings + main scene + default theme |
| `MyHomePage` (custom) | The home screen                                               | A scene with its script                       |
| `Scaffold`            | Basic screen structure: app bar, body, SnackBar support       | Root `Control` with top bar and content area  |
| `AppBar`              | Top bar showing the title "MyPortfolio"                       | Top panel with a `Label`                      |
| `Text`                | Displays text                                                 | `Label`                                       |
| `Padding`             | Adds empty space around its child                             | `MarginContainer`                             |
| `Column`              | Arranges children vertically                                  | `VBoxContainer`                               |
| `Row`                 | Arranges children horizontally                                | `HBoxContainer`                               |
| `Center`              | Centers its child                                             | `CenterContainer`                             |
| `SizedBox`            | Fixed-size empty box, used as vertical spacing                | Spacer with a minimum size                    |
| `GridView.count`      | Grid with a fixed number of columns (3)                       | `GridContainer`                               |
| `Card`                | Raised panel with a shadow, used in `InfoCard`                | `PanelContainer`                              |
| `Container`           | Box with padding and sizing                                   | `Control` / `PanelContainer`                  |
| `Material`            | Colored, rounded surface; needed for tap ripple effects       | `Panel` with a `StyleBoxFlat`                 |
| `InkWell`             | Detects taps and shows a ripple                               | `Button` pressed signal                       |
| `Icon`                | Displays an icon (folder, logout, ...)                        | `TextureRect`                                 |
| `SnackBar`            | Brief message at the bottom of the screen                     | Toast notification                            |
| `ScaffoldMessenger`   | Shows and hides SnackBars                                     | A manager that spawns toasts                  |
| `InfoCard` (custom)   | Reusable card for NPM / Name / Class                          | Reusable scene with exported variables        |
| `ItemCard` (custom)   | Reusable colored button with icon, label and tap feedback     | Reusable button scene                         |

`ItemHomepage` is not a widget. It is a plain data class holding a button's
name, icon and color (similar to a custom `Resource` in Godot).

---

### 3. Purpose of `MaterialApp` and why it is the usual root widget

`MaterialApp` configures everything an app needs at the top level:

- The **theme** (`ThemeData` / `ColorScheme`), which every descendant can read
  through `Theme.of(context)`.
- The **home screen** (`home:`) and **navigation** between screens.
- The **title**, localization and text direction.
- The services Material widgets depend on. `Scaffold`, `SnackBar` and `InkWell`
  need the theme, a `Navigator` and an `Overlay` above them in the tree.

It is the usual root because nearly all apps use Material Design. Placing it at
the top gives every widget below it a theme, navigation and the required
services automatically, without wiring them up by hand. (An app with iOS-style
design would use `CupertinoApp` instead.)

Roughly, it plays the role of Godot's main scene together with the project's
default theme: it decides what starts first and the look that everything
inherits unless overridden.

---

### 4. `StatelessWidget` vs `StatefulWidget`

|                      | `StatelessWidget`                                             | `StatefulWidget`                                       |
| -------------------- | ------------------------------------------------------------- | ------------------------------------------------------ |
| Holds changing data? | No. All values are fixed or passed in through the constructor | Yes. A separate `State` object holds mutable variables |
| Rebuilds when        | Its parent rebuilds or its inputs change                      | Same, and also when `setState()` is called             |
| Complexity           | Simpler                                                       | More code (a widget class plus a state class)          |

**Use `StatelessWidget`** when the UI depends only on the data it is given. In
this project, `MyHomePage`, `InfoCard` and `ItemCard` only display values. The
SnackBar is managed by `ScaffoldMessenger`, so none of them need to store
anything.

**Use `StatefulWidget`** when the widget must remember something that changes
over time and the UI must follow it: a counter, text field input, a checkbox, a
loading flag, an animation. You change the variable inside
`setState(() { ... })`, which tells Flutter to re-run `build()`.

In Godot terms, a stateless widget is like a scene that only shows the values
it was configured with, while a stateful widget is like a script with a
variable such as `score` that changes at runtime. The difference is that in
Godot you manually update the label (`label.text = str(score)`), whereas in
Flutter you change the state inside `setState()` and `build()` redraws the UI
for you.

---

### 5. What is `BuildContext`, and how is it used in `build`?

`BuildContext` is a handle to a widget's **location in the widget tree**.
Flutter passes it to every `build(BuildContext context)` method. Because it
knows where the widget sits, the widget can look **up the tree** to find things
provided by its ancestors.

In this project:

- `Theme.of(context).colorScheme.primary` finds the closest `Theme` above the
  widget (provided by `MaterialApp`) to read the app colors.
- `MediaQuery.of(context).size.width` reads the screen width, used to size
  `InfoCard`.
- `ScaffoldMessenger.of(context)` finds the messenger above the widget so it
  can show a SnackBar.

It is crucial because the same widget can be placed in different parts of the
tree and receive different themes, sizes and services depending on where it is.
This is comparable to a Godot `Control` getting its theme from whichever parent
provides one: the lookup walks up the tree until it finds a match.

---

### 6. Hot reload vs hot restart

- **Hot reload (`r`)** injects the updated code into the running Dart VM and
  rebuilds the widget tree **while keeping the current app state**. It takes
  under a second, which makes it ideal for UI changes such as colors, text and
  layout.
- **Hot restart (`R`)** reloads all code and **restarts the app from scratch**,
  resetting all state. It is still faster than a full rebuild.
- **Full restart** means stopping the app (`q`) and running it again, which
  recompiles everything.

**When hot reload is not enough (use hot restart):**

- Changes to `main()` or other code that only runs at startup.
- Changes to initial values of global or static variables, or to `initState()`
  logic, since these already ran.
- Structural changes to a class, such as adding a field or changing a
  constructor or enum (for example, adding the `color` field to
  `ItemHomepage`).

**When hot restart is not enough (full restart):**

- Editing `pubspec.yaml` (new packages or assets).
- Changing native Android/iOS configuration or permissions.
- Changing app icons, splash screens or build settings.
- On web-server mode, you also need to refresh the browser.

A rough Godot comparison: hot reload is like saving a script while the game is
running and having it pick up the change without losing the current scene state.
Hot restart is like stopping and re-running the scene, which resets everything.
A full restart is like closing and relaunching the project after changing
settings or autoloads.

## Assignment 8

### AI Disclosure

No AI was used to write the code or to copy and paste blindly. I used Claude only as a search engine and to help answer the Reflection Questions. For the form page I followed the structure from Tutorial 09 (including `SingleChildScrollView`) and relied on the autocomplete/suggestions and documentation of the VS Code Flutter extension to figure out how to handle the date. Claude also helped explain a few odd quirks with navigation and with the date output/saving: the date was `null` in the output because it was assigned in `onSaved`, and it should be assigned in `onSubmitted` so the value is already set when it is displayed.

### 1. Differences between `Navigator.push()`, `Navigator.pushReplacement()` and `Navigator.pop()`

| Method                        | What it does                                                          | Back button afterwards          |
| ----------------------------- | --------------------------------------------------------------------- | ------------------------------- |
| `Navigator.push()`            | Puts a new route on top of the stack; the old screen stays underneath | Returns to the previous screen  |
| `Navigator.pushReplacement()` | Replaces the current route with a new one; the old screen is removed  | Cannot return to the old screen |
| `Navigator.pop()`             | Removes the top route and reveals the one below it                    | Same effect as pressing Back    |

The action card on the home screen opens the form with `Navigator.push()`, so the system Back button returns to the home screen. The **Home** option in the drawer uses `Navigator.pushReplacement()` to go to `MyHomePage`, which replaces the form instead of stacking another home screen on top of it.

This is similar to Godot's scene handling: `push` is like adding a scene on top of the current one, while `pushReplacement` is like `change_scene_to_packed()`, which swaps the scene out.

---

### 2. How `Scaffold`, `AppBar` and `Drawer` keep the page structure consistent

`Scaffold` gives every page the same slots (`appBar`, `drawer`, `body`), so only the `body` changes between the home screen and the form page. The same drawer widget (in `lib/widgets/`) is reused on both pages, so navigation looks and behaves the same everywhere.

Example of the theme being reused: `Theme.of(context).colorScheme.primary` colors the `AppBar` on both the home screen and the form page, so changing the theme once in `MaterialApp` updates both.

In Godot terms, `Scaffold` is like a base scene with a top bar and a content area that every screen inherits from.

---

### 3. Why this layout was chosen for the form

The form is a `Form` inside a `SingleChildScrollView`, with `Padding` around a `Column` that stacks the fields, separated by `SizedBox` spacing, and the Save button at the end.

- `Padding` and `SizedBox` keep the fields readable and easy to tap.
- `SingleChildScrollView` makes the content scrollable when screen space is limited (narrow screens or an open keyboard), so Flutter does not throw a "bottom overflowed" error.
- Since the Save button is inside the scrollable area, it always stays reachable.

---

### 4. Roles of `GlobalKey<FormState>`, `validator` and `validate()`

- `GlobalKey<FormState>` is a handle to the `Form`'s state, so the Save button can control all fields at once even though it is not inside any of them.
- `validator` is a function on each field that returns an error message if the value is invalid, or `null` if it is fine.
- `validate()` runs every field's `validator`, shows the error text next to the invalid fields, and returns `true` only if all of them pass. Only then is the summary `AlertDialog` shown.

Example of a value the form rejects: a required field containing only spaces (`"   "`), or an end date earlier than the start date. Choosing an input widget or keyboard type alone is insufficient because it only controls _how_ the user enters data, not _what_ is valid. A text field still accepts spaces or pasted text, and a date picker cannot know that one date must come after another. Only a `validator` can enforce these rules.

## Assignment 9

### AI Disclosure

**Tool:** Claude (claude.ai), in a single chat session: https://claude.ai/share/e7d681a0-c095-4d91-870d-f1268aa88bc5.

**How I worked:** I did not hand the whole assignment to Claude from the start. For Tutorial 10 and this assignment I wrote a first attempt myself (filling in the tutorial TODOs, then writing the Experience and Credential models, `ApiClient` methods, list and detail screens and wiring), ran it, and only then pasted my code and the error output into Claude and asked what was wrong. Most of Claude's contribution was reviewing my code and explaining errors. I applied the fixes myself and re-tested each one against my running Django server. 

**Where Claude wrote code for me:**

- The Project list and detail screens in Tutorial 10, Step 3.2, which I then adapted for Experience and Credential.
- Full replacements for `experience_form_screen.dart` and `credential_form_screen.dart` (login guard, POST with the stored token, `showDatePicker`-based dates, 401 handling), after I sent my Assignment 8 mock forms and asked for fixes. I read through them and tested them against the backend.
- The `_dateToJson` helpers in `credential.dart`, needed because DRF's `DateField` rejects full ISO timestamps.
- Claude acted as a search engine (on steroids) to help me answer the reflective questions.

**What Claude helped me find (I had written the original code):**

- A missing `await` in `AuthState.logout()` and `LoginScreen._submit()`, so errors were never caught.
- A wrong `Content-Type` header, a missing trailing slash on the logout URL, and a form-encoded body where JSON was needed in `ApiClient`.
- The model fields `projectURL` / `projectImageURL`, which `FieldRename.snake` would have mapped to `project_u_r_l` instead of `project_url`.
- A `ChangeNotifierProvider` creating a plain `ChangeNotifier` instead of `AuthState`.
- Per-view `@authentication_classes([SessionAuthentication])` decorators in my Django views, which made them ignore the `Authorization: Token` header and return 403 "credentials were not provided".
- Wrong types and typos in my Credential model (`Image` instead of `String?`, `dyanmic`), missing request bodies in `createExperience` / `createCredential`, and category values that did not match the Django choices.

**Limitations of the AI, and manual fixes:**

- Claude assumed my `REST_FRAMEWORK` setting was still the empty TODO. It was already filled in, and the real cause was the per-view decorators, which I only found after showing the response body in a SnackBar.
- Claude first said that an invalid token returns 401. With `SessionAuthentication` listed first, DRF returns 403. It corrected itself later, and I put `TokenAuthentication` first.
- Claude suggested `pushReplacement` for the "Projects" drawer tile. I questioned it, since it breaks the Back button, and we switched to closing the drawer and using `push`.
- Claude's code snippets used `package:flutter/material.dart` and `myportfolio_mobile`, while my project uses `material_ui` and `myportofolio_mobile`. I had to fix the imports in every file, and `flutter analyze` failed CI until I replaced them.
- The CI APK build failed twice for reasons that were mine: the Android Gradle Plugin version was too old for the current stable Flutter, and I had typed `user-permission` instead of `uses-permission` in `AndroidManifest.xml`. Claude diagnosed both from the logs, and I made the changes.
- Claude's first URL validation idea (`hasAbsolutePath`) was unreliable, so I used a scheme and host check instead.
- Credentials created from the app cannot have an image, because the JSON API cannot accept a file upload without a multipart request. This is a known limitation.
- GitHub Copilot in VS Code helped remove generic homepage tap snackbars and add credential view/add navigation to the homepage and drawer.

### 1. Why @JsonSerializable and @JsonKey(includeToJson: false) instead of raw maps?
They provide compile-time safety, especially against typos (e.g. "porject_name" appears as null in runtime). `fieldRename: snake` converts Dart's camelCase into the Django server's snake_case. `includeToJson: false` is used to skip server-generated fields like id, since sending that in a POST request would make Django reject it (id isn't editable). Concretely, all models have an id field. Moreover, were I to use raw maps, my frequent typos (as mentioned in the AI disclosure) would've been way more of a nuisance.

### 2. Future in initState(), and ApiException instead of null
`build()` runs over and over again, thus a request wouldd be repeatedly sent, whereas `initState()` runs once and waits. A new Future there will cause the loading spinner to flicker. Null, by definition, means unknown or undefined, nothing more to it. So, it'd be impossible to convey any meaning with just null besides its base semantics. An `ApiException` carries both the status code and the message so `FutureBuilder` can show the real error. Exceptions provide null-safety by cutting the null leak from the source basically.

### 3. SessionAuthentication vs TokenAuthentication
Sessions use a browser cookie to authenticate, suitable for websites. Meanwhile, tokens use a string the app sends itself, which suits the Flutter app. Both are needed so both the web and app work. Django Rest Framework accepts either method, so both can coexist. Removing sessions would break the Django website and its admin pages from Tutorial 04/07. More precisely, a session is like a stamp on your hand at a fair. The server remembers you, and the browser sends the cookie automatically. Token is like a ticket you show every time. The app puts it in the Authorization header (extra info sent with each request) itself.

### 4. build (very_good_workflows), build_apk, and gitignoring *.g.dart
`build` checks the quality of the code while `build_apk` (that runs after build) packs it into an installable Android app. `*.g.dart` files are machine-generated copies that CI can reproduce, so they don't belong in git as to not clutter it with non-source-code. CI still works because it runs `build_runner` first, which recreates those files on the CI machine. Without it, it'd fail with "file not found". `very_good_workflows` is a ready-made CI jobthat auto runs each push to the predetermined branches (in this case main/master)/pull request. It typically installs Flutter, gets packages, checks formatting, runs a code-quality checker, and runs tests, often with a coverage check. 