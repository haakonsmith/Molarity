import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.titlebarAppearsTransparent = true
    // self.titleVisibility = .hidden
    self.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
    self.setFrame(windowFrame, display: true)
    self.minSize = NSSize(width: 400, height: 300)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
