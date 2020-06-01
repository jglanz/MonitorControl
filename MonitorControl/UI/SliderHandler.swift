import Cocoa
import DDC

class SliderHandler {
  var slider: NSSlider?
  var display: ExternalDisplay
  let cmd: DDCCommand

  public init(display: ExternalDisplay, command: DDCCommand) {
    self.display = display
    self.cmd = command
  }

  @objc func valueChanged(slider: NSSlider) {
    let snapInterval = 25
    let snapThreshold = 3

    var value = slider.integerValue

    let closest = (value + snapInterval / 2) / snapInterval * snapInterval
    if abs(closest - value) <= snapThreshold {
      value = closest
      slider.integerValue = value
    }

    // For the speaker volume slider, also set/unset the mute command when the value is changed from/to 0
    if self.cmd == .AUDIO_SPEAKER_VOLUME, (self.display.isMuted() && value > 0) || (!self.display.isMuted() && value == 0) {
      self.display.toggleMute(fromVolumeSlider: true)
    }

    // If the command is to adjust brightness, also instruct the display to set the contrast value, if necessary
    if self.cmd == .BRIGHTNESS {
      self.display.setContrastValueForBrightness(value)
    }

    // If the command is to adjust contrast, erase the previous value for the contrast to restore after brightness is increased
    if self.cmd == .CONTRAST {
      self.display.setRestoreValue(nil, for: .CONTRAST)
    }

    let ddcCmd = DDCWriteCommand()
    ddcCmd.controlId = Int(self.cmd.rawValue)
    ddcCmd.newValue = value
    _ = DDCManager().write(ddcCmd, for: self.display.identifier)// self.display.ddc?.write(command: self.cmd, value: UInt16(value))
    self.display.saveValue(value, for: self.cmd)
  }
}
