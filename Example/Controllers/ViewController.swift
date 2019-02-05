//
//  ViewController.swift
//  Example
//
//  Created by Kyle Begeman on 2/4/19.
//  Copyright © 2019 Kyle Begeman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var requestButton: UIButton!
    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        requestButton.backgroundColor = UIColor.white
        requestButton.layer.borderWidth = 1.0
        requestButton.layer.borderColor = UIColor.black.cgColor
        requestButton.layer.cornerRadius = 2.0
    }

    @IBAction func requestButtonPressed(_ sender: UIButton) {

    }

}

