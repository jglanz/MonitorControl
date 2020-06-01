import Cocoa
import DDC
import os.log
class FriendlyNameCellView: NSTableCellView {
  var display: Display?

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }

  @IBAction func valueChanged(_ sender: NSTextFieldCell) {
    if let display = display {
      let newValue = sender.stringValue
      let originalValue = display.ddc?.name ?? display.name

      if newValue.isEmpty {
        self.textField?.stringValue = originalValue
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
