//
//  NewTripStartViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 3/5/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit

class NewTripStartViewController: UIViewController {

    @IBOutlet weak var tripNameTextField: BetterTextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripNameTextField.delegate = self
        doneButton.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done(_ sender: Any) {
        // Create a Trip model here
        let timeStamp = Date().timeIntervalSince1970 * 1000
        let userId = self.delegate.user!.uid
        let tripId = "TRIP-\(userId)-\(timeStamp)"
        let trip = Trip(tripId: tripId, tripName: tripNameTextField.text!, userId: userId, userEmail: delegate.user!.email!, context: delegate.stack.context)
        delegate.stack.save()
        let vc = storyboard?.instantiateViewController(withIdentifier: "NewTripDetailsViewController") as! NewTripDetailsViewController
        vc.trip = trip
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NewTripStartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.characters.count)! > 0 {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
}
