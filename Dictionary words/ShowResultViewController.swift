//
//  ShowResultViewController.swift
//  Dictionary words
//
//  Created by Alexsander  on 10/14/15.
//  Copyright © 2015 Alexsander Khitev. All rights reserved.
//

import UIKit

class ShowResultViewController: UIViewController {

    // MARK: - var and let
    var receiveOrigiganal: String!
    var receiveTranslate: String!
    
    // MARK: - IBOutlet
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    // MARK: - override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredStatusBarStyle()
        self.definesPresentationContext = true
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        firstLabel.text = receiveOrigiganal
        secondLabel.text = receiveTranslate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
