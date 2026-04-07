import Cocoa
import SpriteKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var notchWindow: NSWindow!
    private var settingsWindow: NSWindow?
    private var fishScene: FishScene!
    private var mouseMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupNotchWindow()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "fish.fill", accessibilityDescription: "NotchFish")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Fish", action: #selector(showFish), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Hide Fish", action: #selector(hideFish), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit NotchFish", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc private func showFish() {
        notchWindow.orderFront(nil)
    }

    @objc private func hideFish() {
        notchWindow.orderOut(nil)
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingView = NSHostingView(rootView: settingsView)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 280, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "NotchFish Settings"
            window.contentView = hostingView
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Notch Window

    private func setupNotchWindow() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let windowWidth = screenFrame.width
        let menuBarHeight = screenFrame.maxY - screen.visibleFrame.maxY
        let windowHeight = menuBarHeight + 40
        let windowX = screenFrame.origin.x
        let windowY = screenFrame.maxY - menuBarHeight

        let windowRect = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)

        notchWindow = NSWindow(
            contentRect: windowRect,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        notchWindow.isOpaque = false
        notchWindow.backgroundColor = .clear
        notchWindow.hasShadow = false
        notchWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)))
        notchWindow.collectionBehavior = [.canJoinAllSpaces, .stationary]
        notchWindow.ignoresMouseEvents = true

        var detectedNotchWidth: CGFloat = 0
        if let leftArea = screen.auxiliaryTopLeftArea,
           let rightArea = screen.auxiliaryTopRightArea {
            detectedNotchWidth = rightArea.minX - leftArea.maxX
        }
        let notchWidth = detectedNotchWidth > 10 ? detectedNotchWidth : 0

        let skView = SKView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        skView.allowsTransparency = true
        skView.preferredFramesPerSecond = 30

        fishScene = FishScene(size: CGSize(width: windowWidth, height: windowHeight))
        fishScene.actualNotchWidth = notchWidth
        fishScene.menuBarHeight = menuBarHeight
        fishScene.scaleMode = .resizeFill
        fishScene.backgroundColor = .clear

        skView.presentScene(fishScene)
        notchWindow.contentView = skView
        notchWindow.orderFront(nil)

        startMouseTracking()
    }

    // MARK: - Mouse Tracking

    private func startMouseTracking() {
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            guard let self = self else { return }
            let mouseScreen = NSEvent.mouseLocation
            let windowFrame = self.notchWindow.frame
            let localX = mouseScreen.x - windowFrame.origin.x
            let localY = mouseScreen.y - windowFrame.origin.y
            self.fishScene.updateMousePosition(CGPoint(x: localX, y: localY))
        }
    }
}
