# myportofolio_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
