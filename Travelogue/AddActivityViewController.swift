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
    @IBOutlet weak var activityTextView: UITextView!
    
    var time: Date {
        get {
            return datePicker.date
        }
    }
    
    var activityDescription: String {
        get {
            return activityTextView.text ?? ""
        }
    }
    
    var date: Date!
    let dateFormatter = DateFormatter()
    var screenScrolledUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        let dateComponents = dateString.components(separatedBy: ", ")
        dateLabel.text = dateComponents[0]
        yearLabel.text = dateComponents[1]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension AddActivityViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
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
        if activityTextView.isFirstResponder {
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
