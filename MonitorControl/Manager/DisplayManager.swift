import Cocoa

class DisplayManager {
  public static let shared = DisplayManager()

  private var displays: [Display] {
    didSet {
      NotificationCenter.default.post(name: Notification.Name(Utils.PrefKeys.displayListUpdate.rawValue), object: nil)
    }
  }

  init() {
    self.displays = []
  }

  func updateDisplays(displays: [Display]) {
    self.displays = displays
  }

  func getAllDisplays() -> [Display] {
    return self.displays
  }

  func getDdcCapableDisplays() -> [ExternalDisplay] {
    return self.displays.compactMap { (display) -> ExternalDisplay? in
      if let externalDisplay = display as? ExternalDisplay {
        return externalDisplay
      } else { return nil }
    }
  }

  func getBuiltInDisplay() -> Display? {
    return self.displays.first { $0 is InternalDisplay }
  }

  func getCurrentDisplay() -> Display? {
    return self.displays.first { $0 is ExternalDisplay }
  }

  func addDisplay(display: Display) {
    self.displays.append(display)
  }

  func updateDisplay(display updatedDisplay: Display) {
    if let indexToUpdate = self.displays.firstIndex(of: updatedDisplay) {
      self.displays[indexToUpdate] = updatedDisplay
    }
  }

  func clearDisplays() {
    self.displays = []
  }
}
