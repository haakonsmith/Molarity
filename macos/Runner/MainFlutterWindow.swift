import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
    
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }
    
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

// import Cocoa
// import FlutterMacOS
// import bitsdojo_window_macos

// class MainFlutterWindow: BitsdojoWindow {
//   override func bitsdojo_window_configure() -> UInt {
//     return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
//   }

//   override func awakeFromNib() {
//     let flutterViewController = FlutterViewController.init()
//     let windowFrame = self.frame
//     self.contentViewController = flutterViewController
//     // self.titlebarAppearsTransparent = true
//     // self.titleVisibility = .hidden
//     // self.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
//     self.setFrame(windowFrame, display: true)
//     // self.minSize = NSSize(width: 400, height: 300)

//     RegisterGeneratedPlugins(registry: flutterViewController)

//     super.awakeFromNib()
//   }
// }
