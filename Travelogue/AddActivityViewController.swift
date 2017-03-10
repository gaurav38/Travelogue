//
//  AddActivityViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/4/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit

class AddActivityViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var activityTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var selectTimeButton: UIButton!
    
    var startTime: String {
        get {
            if startTimeTextField.text == nil || startTimeTextField.text == "" {
                return ""
            } else {
                return startTimeTextField.text!
            }
        }
    }
    
    var endTime: String {
        get {
            if endTimeTextField.text == nil || endTimeTextField.text == "" {
                return ""
            } else {
                return endTimeTextField.text!
            }
        }
    }
    
    var activityDescription: String {
        get {
            return activityTextField.text ?? ""
        }
    }
    
    var date: Date!
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var screenScrolledUp = false
    var preSelectedPlace: String?
    var selectingStartTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        dateFormatter.dateFormat = "MMM d, yyyy"
        timeFormatter.dateFormat = "h:mm a"
        let dateComponents = dateFormatter.string(from: date).components(separatedBy: ", ")
        dateLabel.text = dateComponents[0]
        yearLabel.text = dateComponents[1]
        if preSelectedPlace != nil {
            activityTextField.text = preSelectedPlace
        }
    }
    
    @IBAction func selectTime(_ sender: Any) {
        if selectingStartTime {
            startTimeTextField.text = timeFormatter.string(from: datePicker.date)
            selectingStartTime = false
            selectTimeButton.setTitle("Select end time", for: UIControlState.normal)
        } else {
            endTimeTextField.text = timeFormatter.string(from: datePicker.date)
            selectingStartTime = true
            selectTimeButton.setTitle("Select start time", for: UIControlState.normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension AddActivityViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == startTimeTextField {
            selectingStartTime = false
            selectTimeButton.setTitle("Select end time", for: UIControlState.normal)
        } else {
            selectingStartTime = true
            selectTimeButton.setTitle("Select start time", for: UIControlState.normal)
        }
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddActivityViewController {
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if activityTextField.isEditing {
            self.view.frame.origin.y = getKeyboardHeight(notification: notification) * (-1)
            screenScrolledUp = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if screenScrolledUp {
            self.view.frame.origin.y = 0
            screenScrolledUp = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
