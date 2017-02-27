//
//  CreateDayPlanViewController.swift
//  Travelogue
//
//  Created by Gaurav Saraf on 2/26/17.
//  Copyright © 2017 Gaurav Saraf. All rights reserved.
//

import UIKit

class CreateDayPlanViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    var locationNumber: Int!
    var dataContainer: NewTripDataContainer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.placeholder = "Enter city:"
        locationTextField.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CreateDayPlanViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        dataContainer.selectedLocations[locationNumber] = textField.text!
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dataContainer.selectedLocations[locationNumber] = textField.text!
        textField.resignFirstResponder()
        return true
    }
}
