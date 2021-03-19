//
//  ViewController.swift
//  XNavigationBar
//
//  Created by dte2mdj on 01/14/2020.
//  Copyright (c) 2020 dte2mdj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .groupTableViewBackground
        
        navBackground = .image(UIImage(named: "nav01")!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

