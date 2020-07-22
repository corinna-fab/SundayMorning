//
//  FinishRegisterViewController.swift
//  Sunday Morning 2
//
//  Created by Corinna Fabre on 7/22/20.
//  Copyright © 2020 Corinna Fabre. All rights reserved.
//

import UIKit
import SCLAlertView

class FinishRegisterViewController: UIViewController {
    @IBOutlet weak var goalNumber: UILabel!
    @IBOutlet weak var goalSlider: UISlider!
    
    @IBAction func goalSliderSlide(_ sender: Any) {
        goalNumber.text = String(Int(goalSlider.value))
    }
    
    var categoryCollectionStrings: [String] = []
    @IBOutlet weak var categoryCollection: UILabel!
    
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBAction func addCategoryPressed(_ sender: Any) {
        categoryCollectionStrings.append(categoryTextField.text ?? "NOPE")
        categoryTextField.text = ""
        
        DispatchQueue.main.async {
            self.categoryCollection.text = self.categoryCollectionStrings.joined(separator:", ")
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        print("Press press")
        
        DatabaseManager.shared.addUserDetails(goal: Int(goalSlider.value), favoriteCategories: categoryCollectionStrings, completion: { success in
            if success {
                print("User details added")
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont(name: "Farah", size: 20)!,
                    kTextFont: UIFont(name: "Farah", size: 14)!,
                    kButtonFont: UIFont(name: "Farah", size: 14)!,
                    showCloseButton: false,
                    showCircularIcon: false,
                    contentViewColor: #colorLiteral(red: 0.5667160749, green: 0.6758385897, blue: 0.56330055, alpha: 1),
                    contentViewBorderColor: #colorLiteral(red: 0.247261852, green: 0.2675772011, blue: 0.2539684772, alpha: 1)
                )
                
                let timer = SCLAlertView.SCLTimeoutConfiguration.init(timeoutValue: 2.0, timeoutAction: {})
                
                SCLAlertView(appearance: appearance).showTitle(
                    "Success!", // Title of view
                    subTitle: "Your details have been added.", // String of view
                    timeout: timer, // Duration to show before closing automatically, default: 0.0
                    completeText: "Done", // Optional button value, default: ""
                    style: .success, // Styles - see below.
                    colorStyle: 1,
                    colorTextButton: 1
                )
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                print("Failed to send")
                
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryTextField.text = ""
        goalNumber.text = "0"
    }

}
