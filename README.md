# NavigationBarLargeTitleItems

A SwiftUI extension that allows you to add custom trailing views to the large title area of a navigation bar – just like in UIKit. Supports smooth animations during push/pop transitions and responds to the swipe-back gesture.

---

## ✨ Features

- 📌 Add custom views to the trailing side of the large title navigation bar
- 🎬 Smooth fade-in/out animations during navigation transitions
- 🎯 Gesture-aware: responds to swipe-back gesture progress
- 🧩 Works with `NavigationView` and `NavigationStack`

---

## 📦 Installation

### Swift Package Manager

Add this package to your project:

```swift
.package(url: "https://github.com/yourusername/NavigationBarLargeTitleItems.git", from: "1.0.0")
```

Then add `"NavigationBarLargeTitleItems"` to your target dependencies.

---

## 🚀 Usage

<details open>
<summary>Simple Button</summary>
  
```swift
import SwiftUI
import NavigationBarLargeTitleItems

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("Hello, world!")
                .navigationTitle("Profile")
                .navigationBarLargeTitleItems(
                    trailing: ProfileButtonView()
                )
        }
    }
}

struct ProfileButtonView: View {
    var body: some View {
        Button(action: {
            print("Profile button tapped")
        }) {
            Image(systemName: "person.circle")
                .font(.title)
        }
    }
}
```
</details>

<details>
<summary>Button with `@Binding` Action</summary>

```swift
import SwiftUI
import NavigationBarLargeTitleItems

struct ContentView: View {
    @State private var showProfile = false

    var body: some View {
        NavigationStack {
            Text("Hello, world!")
                .navigationTitle("Profile")
                .navigationBarLargeTitleItems(
                    trailing: ProfileBindingButtonView(showProfile: $showProfile)
                )
                .sheet(isPresented: $showProfile) {
                    Text("Profile View")
                }
        }
    }
}

struct ProfileBindingButtonView: View {
    @Binding var showProfile: Bool

    var body: some View {
        Button(action: {
            showProfile = true
        }) {
            Image(systemName: "person.circle")
                .font(.title)
        }
    }
}
```
</details>

<details>
<summary>Static Image Only</summary>

```swift
import SwiftUI
import NavigationBarLargeTitleItems

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("Hello, world!")
                .navigationTitle("Profile")
                .navigationBarLargeTitleItems(
                    trailing: Image(systemName: "person.circle")
                        .font(.title)
                )
        }
    }
}
```
</details>

## 🛠 How It Works

This package uses a hidden `UIViewControllerRepresentable` that injects a `UIHostingController` into the private UIKit class `_UINavigationBarLargeTitleView`. It observes transitions and swipe gestures to animate the trailing content smoothly and contextually.

---

## ⚠️ Notes

- Relies on private UIKit class names (`_UINavigationBarLargeTitleView`), which may break in future iOS versions.
- Supports **iOS 15+**
- Intended for use with `.large` navigation bar style only – not `.inline` or `.automatic`.
