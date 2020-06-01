import Cocoa
import os.log
import DDC
class FriendlyNameCellView: NSTableCellView {
  var display: DDCDisplay?

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }

  @IBAction func valueChanged(_ sender: NSTextFieldCell) {
    if let display = display {
      let newValue = sender.stringValue
      let originalValue = display.name

      if newValue.isEmpty {
        self.textField?.stringValue = originalValue!
        return
      }

      if newValue != originalValue,
        !newValue.isEmpty {
        display.name = newValue
        NotificationCenter.default.post(name: Notification.Name(Utils.PrefKeys.friendlyName.rawValue), object: nil)
        #if DEBUG
          os_log("Value changed for friendly name: %{public}@", type: .info, "from `\(originalValue)` to `\(newValue)`")
        #endif
      }
    }
  }
}
