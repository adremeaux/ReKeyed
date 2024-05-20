//
//  ViewController.swift
//  ReKeyed
//
//  Created by Andy on 5/20/24.
//

import UIKit

enum Note: Int {
  case C = 0
  case Cs
  case D
  case Ds
  case E
//  case Es
  case F
  case Fs
  case G
  case Gs
  case A
  case As
  case B
//  case Bs

  func next() -> Note {
      Note(rawValue: rawValue + 1) ?? .C
  }

  func getHz(octave: Int) -> CGFloat {
    let octMulti = CGFloat(NSDecimalNumber(decimal:pow(2, octave)))
    switch self {
      case .C: return 16.35 * octMulti
      case .Cs: return 17.32 * octMulti
      case .D: return 18.35 * octMulti
      case .Ds: return 19.45 * octMulti
      case .E: return 20.60 * octMulti
      case .F: return 21.83 * octMulti
      case .Fs: return 23.12 * octMulti
      case .G: return 24.50 * octMulti
      case .Gs: return 25.96 * octMulti
      case .A: return 27.50 * octMulti
      case .As: return 29.14 * octMulti
      case .B: return 30.87 * octMulti
    }
  }
}

enum Step {
  case half
  case whole
}

enum Mode: CaseIterable {
  case major
  case minor
  case aeolian
  case dorian
  case ionian
  case locrian
  case lydian
  case mixolydian
  case phrygian

  func getSteps() -> [Step] {
    switch self {
    case .major: return [.whole, .whole, .half, .whole, .whole, .whole, .half]
    case .minor: return [.whole, .half, .whole, .whole, .whole, .whole, .half]

    case .aeolian: return [.whole, .half, .whole, .whole, .half, .whole, .whole]
    case .dorian: return [.whole, .half, .whole, .whole, .whole, .half, .whole]
    case .ionian: return [.whole, .whole, .half, .whole, .whole, .whole, .half]
    case .locrian: return [.half, .whole, .whole, .half, .whole, .whole, .whole]
    case .lydian: return [  .whole, .whole, .whole, .half, .whole, .whole, .half]
    case .mixolydian: return [.whole, .whole, .half, .whole, .whole, .half, .whole]
    case .phrygian: return [.half, .whole, .whole, .whole, .half, .whole, .whole]
    }
  }
}

enum KeyColor {
  case white
  case black
  case highlightWhite
}

class ViewController: UIViewController {

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  var kbView: KeyboardView!
  var pickerVC: PickerViewController!

  override func viewDidLoad() {
    super.viewDidLoad()

    NSLog(Note.Ds.rawValue.description)

    pickerVC = PickerViewController() { mode in
      Task {
        await self.setPattern(mode)
      }
    }
    pickerVC.view.frame = CGRectMake(0.0, 0.0, view.bounds.width, view.bounds.height / 2.0)
    addChild(pickerVC)
    view.addSubview(pickerVC.view)

    kbView  = KeyboardView()
    kbView.frame = CGRectMake(0.0, view.bounds.height / 2.0, view.bounds.width, view.bounds.height / 2.0)
    view.addSubview(kbView)
    kbView.backgroundColor = UIColor.yellow

    Task {
      await setPattern(.major)
    }
  }

  func setPattern(_ mode: Mode) async {
    let pattern = await genPattern(mode, .C)
    kbView.updatePattern(pattern, 2, .C)
  }

  func genPattern(_ mode: Mode, _ rootNote: Note) async -> [KeyColor] {
    let steps = mode.getSteps()
    var keys: [KeyColor] = []
    keys.append(.highlightWhite)
    steps.forEach { step in
      if step == .whole { keys.append(.black) }
      keys.append(.white)
    }
    keys.removeLast() //loops around

    return keys
  }



}

