//
//  InternalDisplay.swift
//  MonitorControl
//
//  Created by Joni Van Roost on 24/01/2020.
//  Copyright © 2020 Guillaume Broder. All rights reserved.
//
//  Most of the code in this file was sourced from:
//  https://github.com/fnesveda/ExternalDisplayBrightness
//  all credit goes to @fnesveda

import Cocoa
import ddc
import Foundation

class InternalDisplay: Display {
  // the queue for dispatching display operations, so they're not performed directly and concurrently
  private var displayQueue: DispatchQueue
  private var screen: NSScreen

  init(_ screen: NSScreen) {
    self.displayQueue = DispatchQueue(label: String("displayQueue-internal"))
    self.screen = screen

    super.init(nil)

    self.name = screen.displayName ?? "Internal Display"
    self.vendorNumber = screen.vendorNumber
//    self.identifier = Int32(screen.displayID)
    self.modelNumber = screen.modelNumber
  }

  func calcNewBrightness(isUp: Bool, isSmallIncrement: Bool) -> Float {
    var step: Float = (isUp ? 1 : -1) / 16.0
    let delta = step / 4
    if isSmallIncrement {
      step = delta
    }
    return min(max(0, ceil((self.getBrightness() + delta) / step) * step), 1)
  }

  public func getBrightness() -> Float {
    self.displayQueue.sync {
      Float(type(of: self).CoreDisplayGetUserBrightness?() ?? 0.5)
    }
  }

  override func stepBrightness(isUp: Bool, isSmallIncrement: Bool) {
    let value = self.calcNewBrightness(isUp: isUp, isSmallIncrement: isSmallIncrement)
    self.displayQueue.sync {
      type(of: self).CoreDisplaySetUserBrightness?(Double(value))
      type(of: self).DisplayServicesBrightnessChanged?(Double(value))
      self.showOsd(command: DDCControl.BRIGHTNESS, value: Int(value * 64), maxValue: 64)
    }
  }

  // notifies the system that the brightness of a specified display has changed (to update System Preferences etc.)
  // unfortunately Apple doesn't provide a public API for this, so we have to manually extract the function from the DisplayServices framework
  private static var DisplayServicesBrightnessChanged: ((Double) -> Void)? {
    let displayServicesPath = CFURLCreateWithString(kCFAllocatorDefault, "/System/Library/PrivateFrameworks/DisplayServices.framework" as CFString, nil)
    if let displayServicesBundle = CFBundleCreate(kCFAllocatorDefault, displayServicesPath) {
      if let funcPointer = CFBundleGetFunctionPointerForName(displayServicesBundle, "DisplayServicesBrightnessChanged" as CFString) {
        typealias DSBCFunctionType = @convention(c) (Double) -> Void
        return unsafeBitCast(funcPointer, to: DSBCFunctionType.self)
      }
    }
    return nil
  }

  // reads the brightness of a display through the CoreDisplay framework
  // unfortunately Apple doesn't provide a public API for this, so we have to manually extract the function from the CoreDisplay framework
  private static var CoreDisplayGetUserBrightness: (() -> Double)? {
    let coreDisplayPath = CFURLCreateWithString(kCFAllocatorDefault, "/System/Library/Frameworks/CoreDisplay.framework" as CFString, nil)
    if let coreDisplayBundle = CFBundleCreate(kCFAllocatorDefault, coreDisplayPath) {
      if let funcPointer = CFBundleGetFunctionPointerForName(coreDisplayBundle, "CoreDisplay_Display_GetUserBrightness" as CFString) {
        typealias CDGUBFunctionType = @convention(c) () -> Double
        return unsafeBitCast(funcPointer, to: CDGUBFunctionType.self)
      }
    }
    return nil
  }

  // sets the brightness of a display through the CoreDisplay framework
  // unfortunately Apple doesn't provide a public API for this, so we have to manually extract the function from the CoreDisplay framework
  private static var CoreDisplaySetUserBrightness: ((Double) -> Void)? {
    let coreDisplayPath = CFURLCreateWithString(kCFAllocatorDefault, "/System/Library/Frameworks/CoreDisplay.framework" as CFString, nil)
    if let coreDisplayBundle = CFBundleCreate(kCFAllocatorDefault, coreDisplayPath) {
      if let funcPointer = CFBundleGetFunctionPointerForName(coreDisplayBundle, "CoreDisplay_Display_SetUserBrightness" as CFString) {
        typealias CDSUBFunctionType = @convention(c) (Double) -> Void
        return unsafeBitCast(funcPointer, to: CDSUBFunctionType.self)
      }
    }
    return nil
  }
}
