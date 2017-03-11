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
    let dataContainer = NewTripDataContainer.instance
    let firebaseService = FirebaseService.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripNameTextField.delegate = self
        doneButton.isEnabled = false
        dataContainer.reset()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateTripDetails" {
            // Create a Trip model here
            let timeStamp = Int((Date().timeIntervalSince1970 * 1000).rounded())
            let userId = self.delegate.user!.uid
            let tripId = "TRIP_\(userId)_\(timeStamp)"
            firebaseService.createTrip(id: tripId, name: tripNameTextField.text!)
            dataContainer.tripId = tripId
            dataContainer.tripName = tripNameTextField.text!
            
            let vc = segue.destination as! NewTripDetailsViewController
            vc.dataContainer = dataContainer
            vc.firebaseService = firebaseService
        }
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
