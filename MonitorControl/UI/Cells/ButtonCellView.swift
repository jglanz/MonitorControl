import Cocoa
import os.log
import DDC

class ButtonCellView: NSTableCellView {
  @IBOutlet var button: NSButton!
  var display: DDCDisplay?

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }

  @IBAction func buttonToggled(_ sender: NSButton) {
    if let display = display {
      let isEnabled = sender.state == .on
//      display.isEnabled = isEnabled
      #if DEBUG
        os_log("Toggle enabled display state: %{public}@", type: .info, isEnabled ? "on" : "off")
      #endif
    }
  }
}
