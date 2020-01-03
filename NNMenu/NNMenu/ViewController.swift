//
//  ViewController.swift
//  NNMenu
//
//  Created by NAVEEN NAUTIYAL on 25/12/19.
//  Copyright © 2019 NAVEEN NAUTIYAL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var menuButton: UIButton!;
    @IBOutlet weak var menuButton2: UIButton!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func tapOnButton () {
        
    }
    
    
    @IBAction func tapOnButton2 () {
        
        let input = ["items" : ["Home", "Profile", "<br>" ,"Contact Us", "<br>" , "About Us"],
                     "inner": ["Home" : ["items" : ["Home Sub 1", "Home Sub 2", "<br>" , "Home Sub 3", "Home Sub 4"]],
                               "Contact Us" : ["items" : ["Send Email", "Call Us"],
                                               "inner" : ["Call Us" : ["items" : ["245678734", "<br>" , "76876876898"]],
                                                          "Send Email" : ["items" : ["info@menu.com", "care@menu.com"]]]]
            ]] as [String : Any];
        
        let menuView = NNMenuView.init(data: input, ancherView: self.menuButton2 as AnyObject);
        // Color for dynamic border "<br>"
        menuView.borderColor = UIColor.systemTeal.withAlphaComponent(0.6);
        // Cell Selection style, you have 3 choices
        menuView.cellSelectionStyle = .bothFontandBackgroundColor;
        self.view.addSubview(menuView);
        menuView.delegate = self;
        menuView.setupMenuView();
    }
}

extension ViewController: NNMenuViewDelegate {
    
    func menuItemFontColorFor(item: String) -> UIColor? {
        return UIColor.systemTeal;
    }
    
    func menuItemSelectedFontColorFor(item: String) -> UIColor? {
        return UIColor.black;
    }
    
    // ----------
    
    func menuViewColorForSelection() -> UIColor? {
        return UIColor.systemOrange;
    }
    
    func menuViewColorForUnSelected() -> UIColor? {
        return UIColor.white;
    }

    //------------
    func menuItemFontFor(item: String) -> UIFont? {
        return nil
    }
    
    func menuViewCellHeightFor(item: String) -> CGFloat? {
        return nil;
    }
    
    func menuView(menuView: NNMenuView, itemSelected item: String, innerMenuAvailable menu: Bool) {
        print("Selected : \(item)");
        if !menu {
            print("Nothing to show now : Closing the menu");
            menuView.removeFromSuperview();
        }
    }
    
    
}
