//
//  KeyboardView.swift
//  AlternateKeyboard
//
//  Created by Andy on 5/20/24.
//

import UIKit
import AudioKit
import SoundpipeAudioKit

class KeyboardView: UIView, HasAudioEngine {
  private class KeyData: NSObject {
    var rect: CGRect
    var color: KeyColor
    var note: Note
    var octave: Int = 0

    init(rect: CGRect, color: KeyColor, note: Note, octave: Int) {
      self.rect = rect
      self.color = color
      self.note = note
      self.octave = octave + 3
    }

    public override var description: String {
      return "Note: \(note) | Octave: \(octave) | Rect: \(rect)"
    }
  }

  private var keyPattern: [KeyColor] = []
  private var octaves: Int = 1
  private var rootNote: Note = .C
  private var keyData: [KeyData] = []

  let engine = AudioEngine()
  var osc = Oscillator()

  override init(frame frameRect: CGRect) {
    super.init(frame: frameRect)

    osc.amplitude = 0.5
    engine.output = osc
    self.start()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    osc.amplitude = 0.5
    engine.output = osc
  }

  public func updatePattern(_ pattern: [KeyColor], _ octaves: Int, _ rootNote: Note) {
    self.keyPattern = pattern
    self.octaves = octaves
    self.rootNote = rootNote

    keyData = []
    var curNote = rootNote

    (0..<octaves).forEach { oct in
      pattern.forEach { kc in
        keyData.append(KeyData(rect: CGRectZero, color: kc, note: curNote, octave: oct))
        curNote = curNote.next()
      }
    }
    keyData.append(KeyData(rect: CGRectZero, color: .highlightWhite, note: curNote, octave: octaves))

    setNeedsDisplay()
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }
    NSLog("draw")

    let whites = keyData.filter({ $0.color == .white || $0.color == .highlightWhite })

    let strokeWidth = 5.0
    let halfStroke = strokeWidth / 2.0
    let whiteWidth = (rect.width - strokeWidth) / CGFloat(whites.count)
    let blackWidth = whiteWidth * 0.5

    context.setFillColor(UIColor.white.cgColor)
    context.setStrokeColor(UIColor.black.cgColor)

    for (i, keyData) in whites.enumerated() {
      context.setFillColor(keyData.color == .white ? UIColor.white.cgColor :
                           UIColor(hue: 0.37, saturation: 1.0, brightness: 0.94, alpha: 1.0).cgColor)

      let r = CGRectMake(CGFloat(i) * whiteWidth + halfStroke, halfStroke, whiteWidth, rect.height - strokeWidth)
      context.fill(r)
      let sr = i == 0 ? r : CGRectMake(r.minX - halfStroke, r.minY, r.width + halfStroke, r.height)
      context.stroke(sr, width: strokeWidth)

      keyData.rect = r
    }

    context.setFillColor(UIColor.black.cgColor)
    var whitePos = 0
    for (_, k) in keyData.enumerated() {
      if k.color == .white || k.color == .highlightWhite {
        whitePos += 1
        continue
      }

      let r = CGRectMake(CGFloat(whitePos) * whiteWidth - blackWidth / 2.0, 0, blackWidth, rect.height * 0.6)
      context.fill(r)
      k.rect = r
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let point = touch.location(in: self)

    let blackHits = keyData.filter {
      $0.color == .black &&
      $0.rect.contains(point)
    }
    blackHits.forEach { NSLog($0.description) }
    if blackHits.count >= 1 {
      playNote(keyData: blackHits.first!)
      return
    }

    let anyHits = keyData.filter {
      $0.rect.contains(point)
    }
    anyHits.forEach { NSLog($0.description) }
    if anyHits.count >= 1 {
      playNote(keyData: anyHits.first!)
      return
    }

    NSLog("no note found for touch: \(touch)")
  }

  private func playNote(keyData: KeyData) {
    let freq = Float(keyData.note.getHz(octave: keyData.octave))
    NSLog(keyData.description)
    NSLog("\(freq)")
//    playPureTone(frequencyInHz: Float(keyData.note.getHz(octave: keyData.octave)), amplitude: 1.0, durationInMillis: 250) {}

    osc.start()
    osc.frequency = freq
    osc.amplitude = 0.3
  }

  private func stopNote() {
    osc.stop()
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    stopNote()
  }
}
