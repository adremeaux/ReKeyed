//
//  PickerViewController.swift
//  ReKeyed
//
//  Created by Andy on 5/20/24.
//

import UIKit

class PickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  required init?(coder: NSCoder) {
    self.updateFunc = { _ in }
    super.init(coder: coder)
  }

  var picker: UIPickerView!
  let updateFunc: (Mode) -> Void

  init(updateFunc: @escaping (Mode) -> Void) {
    self.updateFunc = updateFunc
    super.init(nibName:nil, bundle:nil)
  }

  override func viewDidLoad() {
    picker = UIPickerView(frame: CGRectMake(100, 100, 200, 300))
    view.addSubview(picker)
    picker.delegate = self
    picker.dataSource = self
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return Mode.allCases.count
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return String(describing: Mode.allCases[row])
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    updateFunc(Mode.allCases[row])
  }
}
