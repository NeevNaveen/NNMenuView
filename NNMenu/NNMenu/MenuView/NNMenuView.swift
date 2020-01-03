//
//  NNMenuView.swift
//  NNMenu
//
//  Created by NAVEEN NAUTIYAL on 25/12/19.
//  Copyright © 2019 NAVEEN NAUTIYAL. All rights reserved.
//

import UIKit

protocol NNMenuViewDelegate {
    
    // Cosmetic Delegates for the Menu Items dealing with Selection Background Color
    func menuViewColorForSelection()-> UIColor?;
    func menuViewColorForUnSelected()-> UIColor?;
    
    // Cosmetic Delegates for the Menu Items dealing with Selection Font Color
    func menuItemFontColorFor(item: String)-> UIColor?;
    func menuItemSelectedFontColorFor(item: String)-> UIColor?;
    
    // Delegate to handle Font style for text
    func menuItemFontFor(item: String)-> UIFont?;
    
    // Delegate to handle height for cell
    func menuViewCellHeightFor(item: String)-> CGFloat?;
    
    
    /// This method is to tell us that which item is selected
    /// - Parameters:
    ///   - menuView: Reference to Self, so that parent can remove it if needed
    ///   - item: String for the item selected.
    ///   - menu: A bool value which will tell us if selected item has inner menu or not.
    func menuView( menuView: NNMenuView, itemSelected item: String, innerMenuAvailable menu: Bool);
}

enum CellSelectionStyle {
    case changeBackgroundColor
    case changeFontColor
    case bothFontandBackgroundColor
}


class NNMenuView: UIView {

    /// This property is to hold the Data to create the menu
    private var menuData: Dictionary<String, Any> = [:];
    private var sortedMenuData: Dictionary<String, Array<String>> = [:];
    private var menuCardsArray: Array<UIView> = [];
    
    
    var delegate: NNMenuViewDelegate?;
    
    var anchorView: AnyObject?;
    
    var cellHeight: CGFloat = 30;
    
    var borderHeight: CGFloat = 5;
    
    var textFont: UIFont = UIFont.init(name: "Georgia-Bold", size: 17)!;
    
    var textColor: UIColor = UIColor.black;
    
    var textColorSelected: UIColor = UIColor.systemOrange;
    
    var unSelectedColor: UIColor = UIColor.white;
    
    var selectedColor: UIColor = UIColor.systemYellow;
    
    var borderColor: UIColor = UIColor.green.withAlphaComponent(0.4);
    
    var visibleColumnWidth = UIScreen.main.bounds.size.width / 1.5;
    
    var cellSelectionStyle: CellSelectionStyle = .changeFontColor;
    
    /// Custom Init Method to initialize the parameter which will help in rendering the View
    /// - Parameters:
    ///   - data: This is the JSON which Class needs to create the heirarchy of the Menu Options
    ///   - ancherView: This is the view which will be anchor for showing the Menu UI in the superview
    ///
    /// - Data JSON Rules
    ///     -   Main Options will be under key 'items'
    ///     -   Inner options for a menu option will be under key 'inner'
    ///     -   Items inside 'items' will work as key under 'inner'
    ///     -   If you want to add a space under any menu option just add "<br>" in the "items" array after that option
    ///
    /// - Example :
    ///             let input = ["items" : ["Home", "Profile", "Contact Us", "About Us"],
    ///                     "inner": ["Home" : ["items" : ["Home Sub 1", "Home Sub 2", "Home Sub 3", "Home Sub 4"]],
    ///                            "Contact Us" : ["items" : ["Send Email", "Call Us"],
    ///                                        "inner" : ["Call Us" : ["items" : ["245678734", "76876876898"]],
    ///                                        "Send Email" : ["items" : ["info@menu.com", "care@menu.com"]]]]]] as [String : Any];
    ///
    public convenience init(data: Dictionary<String, Any>, ancherView: AnyObject?) {
        
        let h = UIScreen.main.bounds.size.height;
        let w = UIScreen.main.bounds.size.width;
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: w, height: h));
        self.menuData = data;
        self.visibleColumnWidth = w * 0.3;
        
        if ancherView != nil
        {
            self.anchorView = ancherView;
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}




// PUBLIC METHODS
extension NNMenuView {
    
    /// Call this if you are ready to show the menu view and all the setup is done.
    public func setupMenuView() {
        
        let itemArray = self.menuData["items"] as! Array<String>;
        self.sortedMenuData["items"] = itemArray;
        self.traverseJsonForInnerOptions(itemArray: itemArray, withInput: self.menuData);
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapOnSuperView));
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        self.addGestureRecognizer(tapGesture);
        
        //print("We have final sorted Menu JSON :  \(self.sortedMenuData)");
        // Now Showing MenuView on the super view.
        self.backgroundColor = UIColor.lightText.withAlphaComponent(0.4);
        self.tag = 100; // so viewWithTag does not confuse
        self.showPopupViewForKey(key: "items");
    }
}




// PRIVATE METHODS
extension NNMenuView {

    
    fileprivate func traverseJsonForInnerOptions(itemArray: Array<String>, withInput input: Dictionary<String, Any>) {
        
        let inner = ( input["inner"] as? Dictionary<String, Any> ) ?? input;
        for item in itemArray
        {
            if let list = getSubMenuListForMenuItem(item: item, fromInut: inner) {
                self.sortedMenuData[item] = list;
                if let nextInut = inner[item] as? Dictionary<String, Any>
                {
                    if let nextInner = nextInut["inner"] as? Dictionary<String, Any>
                    {
                        traverseJsonForInnerOptions(itemArray: list, withInput: nextInner);
                    }
                }
            }
        }
    }
    
    fileprivate func getSubMenuListForMenuItem(item: String, fromInut input: Dictionary<String, Any>)-> Array<String>?
    {
        // IF we have items this means we got the array list which we need to show
        if item == "items" {
            let itemArray = input["items"] as! Array<String>;
            return itemArray;
        }
        // We didn't got items that means we are in inner nodes so using reccursion
         if let obj = input[item] {
            return getSubMenuListForMenuItem(item: "items", fromInut: obj as! Dictionary<String, Any>);
        }
        return nil;
    }
    
    
    
    
    /// Here we will fetch the items array from the sorted Menu Items to create View and Show on Screen.
    /// - Parameter key: This string is actually is a dictionary key, with which we will
    fileprivate func showPopupViewForKey(key: String) {
        
        if let itemList = self.sortedMenuData[key] {
            
            // Pass message via delegate regarding the selected item
            self.delegate?.menuView(menuView: self, itemSelected: key, innerMenuAvailable: true);
            
            let viewToShow = getViewForItemLists(list: itemList);
            viewToShow.center = CGPoint(x: viewToShow.center.x-200, y: viewToShow.center.y);
            self.addSubview(viewToShow);
            
            // Adding subview with animation
            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                viewToShow.center = CGPoint(x: viewToShow.center.x+200, y: viewToShow.center.y);
            }, completion: nil);
            
        } else {
            // Pass message via delegate regarding the selected item
            self.delegate?.menuView(menuView: self, itemSelected: key, innerMenuAvailable: false);
        }
    }
    
    
    /// This method will go through a list of strings and create a view with items as per in the list
    /// - Parameter list: Array of String
    fileprivate func getViewForItemLists(list: Array<String>)-> UIView
    {
        let v = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: self.visibleColumnWidth, height: 0.0));
        v.backgroundColor = UIColor.white;
        
        // Height of the window according to Delegate or a fix value
        var totalHeight: CGFloat = 0;
        
        // This index is to keep track of number of windows we have created
        let index = self.menuCardsArray.count;
        
        for i in 0..<list.count
        {
            let item = list[i];
            
            if item != "<br>" {
                let menuItemView = self.getViewForItem(item: item, atIndex: index, forYaxis: totalHeight);
                v.addSubview(menuItemView);
                totalHeight += self.cellHeight;
            } else {
                let border = self.getBorderView(yaxis: totalHeight);
                v.addSubview(border);
                totalHeight += self.borderHeight;
            }
        }
        
        if index == 0 {
            if let origin = self.anchorView?.frame?.origin
            {
                let margin = UIScreen.main.bounds.size.height - origin.y;
                if margin > UIScreen.main.bounds.size.height * 0.6
                {
                    // We have plenty of space down
                    v.frame = CGRect(x: 10, y: origin.y + (self.anchorView?.frame?.size.height ?? 0), width: v.frame.size.width, height: totalHeight);
                }
                else
                {
                    // we have plenty of space above
                    v.frame = CGRect(x: 10, y: origin.y - (totalHeight), width: v.frame.size.width, height: totalHeight);
                }
            }
        } else {
            let previousView = self.menuCardsArray[index-1];
            v.frame = CGRect(x: previousView.frame.origin.x + previousView.frame.size.width+2, y: previousView.frame.origin.y, width: v.frame.size.width, height: totalHeight);
        }

        v.tag = index;
        self.menuCardsArray.append(v);
        return v;
    }
    
    
    /// This method will create button to place as menu items and attacch an action to each
    /// - Parameters:
    ///   - item: String for title of button, which denotes the Menu Option
    ///   - index: Position of Item in the Array
    ///   - y: Location on Y axis
    fileprivate func getViewForItem(item: String, atIndex index: Int, forYaxis y: CGFloat) -> UIButton {
        
        if let h = self.delegate?.menuViewCellHeightFor(item: item) {
            self.cellHeight = h;
        }
        
        let btn = UIButton.init(type: .custom);
        btn.frame = CGRect(x: 0, y: y, width: self.visibleColumnWidth, height: self.cellHeight);
        btn.setTitle(item, for: .normal);
        btn.tag = index;
        
        if let font = self.delegate?.menuItemFontFor(item: item) {
            self.textFont = font;
        }
        btn.titleLabel?.font = self.textFont;
        btn.titleLabel?.textAlignment = .left;
        
        if let textColor = self.delegate?.menuItemFontColorFor(item: item) {
            self.textColor = textColor;
        }
        btn.setTitleColor(self.textColor, for: .normal);
        btn.titleLabel?.adjustsFontSizeToFitWidth = true;
        
        btn.addTarget(self, action: #selector(tapOnMenuItem(sender:)), for: .touchUpInside);
        
        return btn;
    }
    
    
    /// This method will create a border between menu items
    /// - Parameter yaxis: Location on Y axis.
    fileprivate func getBorderView(yaxis: CGFloat)-> UIView {
        let b = UIView.init(frame: CGRect(x: 0, y: yaxis, width: self.visibleColumnWidth, height: self.borderHeight));
        b.backgroundColor = self.borderColor;
        return b;
    }
    
    
    /// Action method for Menu Item bttons
    /// - Parameter sender: Reference of the button which recieves the user's interaction
    @objc fileprivate func tapOnMenuItem(sender: UIButton)
    {
//        if let v = self.viewWithTag(sender.tag)
//        {
//            v.frame = CGRect(x: v.frame.origin.x, y: v.frame.origin.y, width: v.frame.size.width * 0.5, height: v.frame.size.height);
//            v.layoutIfNeeded();
//        }
//        return;
        
        // Removing Extra Open Window if there are any
        var count = self.menuCardsArray.count-1;
        while count != sender.tag {
            self.menuCardsArray.remove(at: count);
            if let v = self.viewWithTag(count)
            {
                v.removeFromSuperview();
            }
            count = self.menuCardsArray.count-1;
        }
        
        // Changing The Selection Color
        if let v = self.viewWithTag(sender.tag)
        {
            for sv in v.subviews {
                if let btn = sv as? UIButton
                {
                    if btn.titleLabel?.text == sender.titleLabel?.text {
                        
                        if let color = self.delegate?.menuViewColorForSelection() {
                            self.selectedColor = color;
                        }
                        
                        if let color = self.delegate?.menuItemSelectedFontColorFor(item: btn.titleLabel!.text!) {
                            self.textColorSelected = color;
                        }
                        
                        if self.cellSelectionStyle == .changeBackgroundColor {
                            btn.backgroundColor = self.selectedColor;
                        } else if self.cellSelectionStyle == .changeFontColor {
                            btn.setTitleColor(self.textColorSelected, for: .normal);
                        } else {
                            btn.backgroundColor = self.selectedColor;
                            btn.setTitleColor(self.textColorSelected, for: .normal);
                        }
                        
                    }
                    else
                    {
                        if let color = self.delegate?.menuViewColorForUnSelected() {
                            self.unSelectedColor = color;
                        }
                        
                        if let color = self.delegate?.menuItemFontColorFor(item: btn.titleLabel!.text!) {
                            self.textColor = color;
                        }
                        
                        if self.cellSelectionStyle == .changeBackgroundColor {
                            btn.backgroundColor = self.unSelectedColor;
                        } else if self.cellSelectionStyle == .changeFontColor {
                            btn.setTitleColor(self.textColor, for: .normal);
                        } else {
                            btn.backgroundColor = self.unSelectedColor;
                            btn.setTitleColor(self.textColor, for: .normal);
                        }
                    }
                }
            }
        }
        
        // Asking for inner menu card if available
        if let title = sender.titleLabel?.text
        {
            self.showPopupViewForKey(key: title);
        }
    }
    
    
    
    /// This method is to get the touch on superview so that we can close the menu when touch outside
    @objc fileprivate func tapOnSuperView () {
        self.removeFromSuperview();
    }
}
