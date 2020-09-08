import AVFoundation
import Cocoa
import ddc
import os.log

class ExternalDisplay: Display {
  static let ddc = DDCManager()

  var brightnessSliderHandler: SliderHandler?
  var volumeSliderHandler: SliderHandler?
  var contrastSliderHandler: SliderHandler?
//  var ddc: DDC?
//  var ddcDisplay: DDCDisplay

  private let prefs = UserDefaults.standard

  var hideOsd: Bool {
    get {
      return self.prefs.bool(forKey: "hideOsd-\(self.identifier)")
    }
    set {
      self.prefs.set(newValue, forKey: "hideOsd-\(self.identifier)")
      os_log("Set `hideOsd` to: %{public}@", type: .info, String(newValue))
    }
  }

  var needsLongerDelay: Bool {
    get {
      return self.prefs.object(forKey: "longerDelay-\(self.identifier)") as? Bool ?? false
    }
    set {
      self.prefs.set(newValue, forKey: "longerDelay-\(self.identifier)")
      os_log("Set `needsLongerDisplay` to: %{public}@", type: .info, String(newValue))
    }
  }

  private var audioPlayer: AVAudioPlayer?
  private let osdChicletBoxes: Float = 16

  override init(_ ddc: DDCDisplay?) {
    super.init(ddc)
//    self.ddcDisplay = identifier
    // self.ddc = DDC(for: identifier)
  }

  // On some displays, the display's OSD overlaps the macOS OSD,
  // calling the OSD command with 1 seems to hide it.
  func hideDisplayOsd() {
    guard self.hideOsd else {
      return
    }

//    for _ in 0..<20 {
//      _ = self.ddc?.write(command: .osd, value: UInt16(1), errorRecoveryWaitTime: 2000)
//    }
  }

  func isMuted() -> Bool {
    return self.getValue(for: .AUDIO_MUTE) == 1
  }

  func toggleMute(fromVolumeSlider _: Bool = false) {
//    var muteValue: Int
//    var volumeOSDValue: Int

//    if !self.isMuted() {
//      muteValue = 1
//      volumeOSDValue = 0
//    } else {
//      muteValue = 2
//      volumeOSDValue = self.getValue(for: .audioSpeakerVolume)
//
//      // The volume that will be set immediately after setting unmute while the old set volume was 0 is unpredictable
//      // Hence, just set it to a single filled chiclet
//      if volumeOSDValue == 0 {
//        volumeOSDValue = self.stepSize(for: .audioSpeakerVolume, isSmallIncrement: false)
//        self.saveValue(volumeOSDValue, for: .audioSpeakerVolume)
//      }
//    }
//
//    let volumeDDCValue = UInt16(volumeOSDValue)
//
//    guard self.ddc?.write(command: .audioSpeakerVolume, value: volumeDDCValue) == true else {
//      return
//    }

//    if self.supportsMuteCommand() {
//      guard self.ddc?.write(command: .audioMuteScreenBlank, value: UInt16(muteValue)) == true else {
//        return
//      }
//    }

//    self.saveValue(muteValue, for: .AUDIO_MUTE)
//
//    if !fromVolumeSlider {
//      self.hideDisplayOsd()
//      //self.showOsd(command: volumeOSDValue > 0 ? .audioSpeakerVolume : .audioMuteScreenBlank, value: volumeOSDValue)
//
//      if volumeOSDValue > 0 {
//        self.playVolumeChangedSound()
//      }
//
    ////      if let slider = self.volumeSliderHandler?.slider {
    ////        slider.intValue = Int32(volumeDDCValue)
    ////      }
//    }
  }

  func stepVolume(isUp _: Bool, isSmallIncrement _: Bool) {
//    var muteValue: Int?
//    let volumeOSDValue = self.calcNewValue(for: .AUDIO_SPEAKER_VOLUME, isUp: isUp, isSmallIncrement: isSmallIncrement)
//    let volumeDDCValue = UInt16(volumeOSDValue)
//
//    if self.isMuted(), volumeOSDValue > 0 {
//      muteValue = 2
//    } else if !self.isMuted(), volumeOSDValue == 0 {
//      muteValue = 1
//    }
//
//    let isAlreadySet = volumeOSDValue == self.getValue(for: .audioSpeakerVolume)
//
//    if !isAlreadySet {
//      guard self.ddc?.write(command: .audioSpeakerVolume, value: volumeDDCValue) == true else {
//        return
//      }
//    }

//    if let muteValue = muteValue {
//      // If the mute command is supported, set its value accordingly
//      if self.supportsMuteCommand() {
//        guard DDCManager().write(command: .AUD, value: UInt16(muteValue)) == true else {
//          return
//        }
//      }
//      self.saveValue(muteValue, for: .audioMuteScreenBlank)
//    }
//
//    self.hideDisplayOsd()
//    self.showOsd(command: .audioSpeakerVolume, value: volumeOSDValue)
//
//    if !isAlreadySet {
//      self.saveValue(volumeOSDValue, for: .audioSpeakerVolume)
//
//      if volumeOSDValue > 0 {
//        self.playVolumeChangedSound()
//      }
//
//      if let slider = self.volumeSliderHandler?.slider {
//        slider.intValue = Int32(volumeDDCValue)
//      }
//    }
  }

  override func stepBrightness(isUp: Bool, isSmallIncrement: Bool) {
    let osdValue = Int(self.calcNewValue(for: .BRIGHTNESS, isUp: isUp, isSmallIncrement: isSmallIncrement))
    let isAlreadySet = osdValue == self.getValue(for: .BRIGHTNESS)
    let ddcValue = UInt16(osdValue)

    // Set the contrast value according to the brightness, if necessary
    if !isAlreadySet {
      self.setContrastValueForBrightness(osdValue)
    }

    if !isAlreadySet {
      let cmd = DDCWriteCommand(controlId: DDCControl.BRIGHTNESS.rawValue, andValue: CUnsignedInt(ddcValue)) // (DDCControl)
      guard self.ddc?.write(cmd) == true else {
        return
      }
    }

    self.showOsd(command: DDCControl.BRIGHTNESS, value: osdValue)

    if !isAlreadySet {
      if let slider = self.brightnessSliderHandler?.slider {
        slider.intValue = Int32(ddcValue)
      }

      self.saveValue(osdValue, for: .BRIGHTNESS)
    }
  }

  func setContrastValueForBrightness(_ brightness: Int) {
    var contrastValue: Int?

    if brightness == 0 {
      contrastValue = 0

      // Save the current DDC value for contrast so it can be restored, even across app restarts
      if self.getRestoreValue(for: .CONTRAST) == 0 {
        self.setRestoreValue(self.getValue(for: .CONTRAST), for: .CONTRAST)
      }
    } else if self.getValue(for: .BRIGHTNESS) == 0, brightness > 0 {
      contrastValue = self.getRestoreValue(for: .CONTRAST)
    }

    // Only write the new contrast value if lowering contrast after brightness is enabled
    if let contrastValue = contrastValue, self.prefs.bool(forKey: Utils.PrefKeys.lowerContrast.rawValue) {
      let cmd = DDCWriteCommand(controlId: DDCControl.CONTRAST.rawValue, andValue: UInt32(contrastValue))
      _ = self.ddc!.write(cmd)
      self.saveValue(contrastValue, for: .CONTRAST)

      if let slider = contrastSliderHandler?.slider {
        slider.intValue = Int32(contrastValue)
      }
    }
  }

  func readDDCValues(for command: DDCControl, tries _: UInt, minReplyDelay _: UInt64?) -> (current: UInt16, max: UInt16)? {
    var values: (UInt16, UInt16)?
    if let ddc = self.ddc {
//    if ddc.supported(minReplyDelay: delay) == true {
//      os_log("Display supports DDC.", type: .debug)
//    } else {
//      os_log("Display does not support DDC.", type: .debug)
//    }

//    if ddc.enableAppReport() == true {
//      os_log("Display supports enabling DDC application report.", type: .debug)
//    } else {
//      os_log("Display does not support enabling DDC application report.", type: .debug)
//    }

      let cmd = DDCReadCommand(controlId: command.rawValue)!
      if ddc.read(cmd) {
        values = (UInt16(cmd.value), UInt16(cmd.maxValue)) // , tries: tries, minReplyDelay: delay)
      }
    }
    return values
  }

  func calcNewValue(for command: DDCControl, isUp: Bool, isSmallIncrement: Bool) -> Int {
    let currentValue = self.getValue(for: command)
    let nextValue: Int

    if isSmallIncrement {
      nextValue = currentValue + (isUp ? 1 : -1)
    } else {
      let filledChicletBoxes = self.osdChicletBoxes * (Float(currentValue) / Float(self.getMaxValue(for: command)))

      var nextFilledChicletBoxes: Float
      var filledChicletBoxesRel: Float = isUp ? 1 : -1

      // This is a workaround to ensure that if the user has set the value using a small step (that is, the current chiclet box isn't completely filled,
      // the next regular up or down step will only fill or empty that chiclet, and not the next one as well - it only really works because the max value is 100
      if (isUp && ceil(filledChicletBoxes) - filledChicletBoxes > 0.15) || (!isUp && filledChicletBoxes - floor(filledChicletBoxes) > 0.15) {
        filledChicletBoxesRel = 0
      }

      nextFilledChicletBoxes = isUp ? ceil(filledChicletBoxes + filledChicletBoxesRel) : floor(filledChicletBoxes + filledChicletBoxesRel)
      nextValue = Int(Float(self.getMaxValue(for: command)) * (nextFilledChicletBoxes / self.osdChicletBoxes))
    }
    return max(0, min(self.getMaxValue(for: command), Int(nextValue)))
  }

  func getValue(for command: DDCControl) -> Int {
    return self.prefs.integer(forKey: "\(command.rawValue)-\(self.identifier)")
  }

  func saveValue(_ value: Int, for command: DDCControl) {
    self.prefs.set(value, forKey: "\(command.rawValue)-\(self.identifier)")
  }

  func saveMaxValue(_ maxValue: Int, for command: DDCControl) {
    self.prefs.set(maxValue, forKey: "max-\(command.rawValue)-\(self.identifier)")
  }

  func getMaxValue(for command: DDCControl) -> Int {
    return self.getMaxValue(for: command.rawValue)
  }

  func getMaxValue(for command: UInt8) -> Int {
    let max = self.prefs.integer(forKey: "max-\(command)-\(self.identifier)")
    return max == 0 ? 100 : max
  }

  func getRestoreValue(for command: DDCControl) -> Int {
    return self.prefs.integer(forKey: "restore-\(command.rawValue)-\(self.identifier)")
  }

  func setRestoreValue(_ value: Int?, for command: DDCControl) {
    self.prefs.set(value, forKey: "restore-\(command)-\(self.identifier)")
  }

  func setPollingMode(_ value: Int) {
    self.prefs.set(String(value), forKey: "pollingMode-\(self.identifier)")
  }

  /*
   Polling Modes:
   0 -> .none     -> 0 tries
   1 -> .minimal  -> 5 tries
   2 -> .normal   -> 10 tries
   3 -> .heavy    -> 100 tries
   4 -> .custom   -> $pollingCount tries
   */
  func getPollingMode() -> Int {
    // Reading as string so we don't get "0" as the default value
    return Int(self.prefs.string(forKey: "pollingMode-\(self.identifier)") ?? "2") ?? 2
  }

  func getPollingCount() -> Int {
    let selectedMode = self.getPollingMode()
    switch selectedMode {
    case 0:
      return PollingMode.none.value
    case 1:
      return PollingMode.minimal.value
    case 2:
      return PollingMode.normal.value
    case 3:
      return PollingMode.heavy.value
    case 4:
      let val = self.prefs.integer(forKey: "pollingCount-\(self.identifier)")
      return PollingMode.custom(value: val).value
    default:
      return 0
    }
  }

  func setPollingCount(_ value: Int) {
    self.prefs.set(value, forKey: "pollingCount-\(self.identifier)")
  }

  private func stepSize(for command: DDCControl, isSmallIncrement: Bool) -> Int {
    return isSmallIncrement ? 1 : Int(floor(Float(self.getMaxValue(for: command)) / self.osdChicletBoxes))
  }

  override func showOsd(command: DDCControl, value: Int, maxValue _: Int = 100) {
    super.showOsd(command: command, value: value, maxValue: self.getMaxValue(for: command))
  }

  private func supportsMuteCommand() -> Bool {
    // Monitors which don't support the mute command - e.g. Dell U3419W - will have a maximum value of 100 for the DDC mute command
    return self.getMaxValue(for: DDCControl.AUDIO_MUTE) == 2
  }

  private func playVolumeChangedSound() {
    let soundPath = "/System/Library/LoginPlugins/BezelServices.loginPlugin/Contents/Resources/volume.aiff"
    let soundUrl = URL(fileURLWithPath: soundPath)

    // Check if user has enabled "Play feedback when volume is changed" in Sound Preferences
    guard let preferences = Utils.getSystemPreferences(),
      let hasSoundEnabled = preferences["com.apple.sound.beep.feedback"] as? Int,
      hasSoundEnabled == 1
    else {
      os_log("sound not enabled", type: .info)
      return
    }

    do {
      self.audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
      self.audioPlayer?.volume = 1
      self.audioPlayer?.prepareToPlay()
      self.audioPlayer?.play()
    } catch {
      os_log("%{public}@", type: .error, error.localizedDescription)
    }
  }
}
