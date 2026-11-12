// Arco — Apple Music on your Roon zones, from the menu bar.
import Carbon.HIToolbox
import SwiftUI

@main
struct ArcoApp: App {
    @StateObject private var model = ArcoModel()

    init() { PanelHotkey.register() }

    var body: some Scene {
        MenuBarExtra {
            MenuView(model: model)
        } label: {
            MenuBarLabel(bridge: model.bridge)
        }
        .menuBarExtraStyle(.window)
    }
}

// ⌃⌥⌘A opens (or closes) Arco's panel from anywhere, as a click on the menu bar icon would. A Carbon hot key: global
// without the Accessibility permission an event tap would need.
enum PanelHotkey {
    private static var ref: EventHotKeyRef?

    static func register() {
        var pressed = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            DispatchQueue.main.async { PanelHotkey.togglePanel() }
            return noErr
        }, 1, &pressed, nil, nil)
        let id = EventHotKeyID(signature: 0x4172_636F /* "Arco" */, id: 1)
        let status = RegisterEventHotKey(UInt32(kVK_ANSI_A), UInt32(controlKey | optionKey | cmdKey), id,
                                         GetApplicationEventTarget(), 0, &ref)
        if status != noErr { Log.note("hotkey: ⌃⌥⌘A not registered (\(status)) — another app holds it") }
    }

    // MenuBarExtra keeps its status item to itself; its button lives in the menu bar's NSStatusBarWindow.
    private static func togglePanel() {
        let window = NSApp.windows.first { $0.className == "NSStatusBarWindow" }
        button(in: window?.contentView)?.performClick(nil)
    }

    private static func button(in view: NSView?) -> NSStatusBarButton? {
        guard let view else { return nil }
        if let button = view as? NSStatusBarButton { return button }
        return view.subviews.lazy.compactMap { button(in: $0) }.first
    }
}
