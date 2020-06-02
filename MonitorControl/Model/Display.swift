//
//  Display.swift
//  MonitorControl
//
//  Created by Joni Van Roost on 24/01/2020.
//  Copyright © 2020 Guillaume Broder. All rights reserved.
//

import ddc
import Foundation

class Display {
  internal var identifier: Int32
  internal let ddc: DDCDisplay?
  internal var name: String
  internal var vendorNumber: UInt32?
  internal var modelNumber: UInt32?
  internal var isEnabled: Bool {
    get {
      return self.prefs.object(forKey: "\(self.identifier)-state") as? Bool ?? true
    }
    set {
      self.prefs.set(newValue, forKey: "\(self.identifier)-state")
    }
  }

  private let prefs = UserDefaults.standard

  internal init(_ ddc: DDCDisplay?) {
    if let ddc = ddc {
      self.identifier = Int32(ddc.index)
      self.ddc = ddc
      self.name = ddc.name
      self.vendorNumber = ddc.vendorId
      self.modelNumber = ddc.productId
    } else {
//      != nil
      self.identifier = -1
      self.ddc = nil
      self.name = "Internal Display"
      self.vendorNumber = 0
      self.modelNumber = 0
    }
  }

  func stepBrightness(isUp _: Bool, isSmallIncrement _: Bool) {}

  func setFriendlyName(_ value: String) {
    self.prefs.set(value, forKey: "friendlyName-\(self.identifier)")
  }

  func getFriendlyName() -> String {
    return self.prefs.string(forKey: "friendlyName-\(self.identifier)") ?? self.name
  }

  func showOsd(command _: DDCControl, value _: Int, maxValue _: Int = 100) {
//    guard let manager = OSDManager.sharedManager() as? OSDManager else {
//      return
//    }

//    var osdImage: Int64!
//    switch command {
//    case .brightness:
//      osdImage = 1 // Brightness Image
//    case .audioSpeakerVolume:
//      osdImage = 3 // Speaker image
//    case .audioMuteScreenBlank:
//      osdImage = 4 // Mute image
//    default:
//      osdImage = 1
//    }
//
//    manager.showImage(osdImage,
//                      onDisplayID: self.identifier,
//                      priority: 0x1F4,
//                      msecUntilFade: 1000,
//                      filledChiclets: UInt32(value),
//                      totalChiclets: UInt32(maxValue),
//                      locked: false)
  }
}
