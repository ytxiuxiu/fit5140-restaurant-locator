//
//  UIScrollViewExtension.swift
//  restaurant-locator
//
//  Created by YINGCHEN LIU on 29/8/17.
//  Copyright © 2017 YINGCHEN LIU. All rights reserved.
//

import UIKit


// ✴️ Attribute:
// StackOverflow: Programmatically scroll a UIScrollView to the top of a child UIView (subview) in Swift
//      https://stackoverflow.com/questions/39018017/programmatically-scroll-a-uiscrollview-to-the-top-of-a-child-uiview-subview-in

extension UIScrollView {
    
    /**
     Scroll to a child view so that it's top is at the top our scrollview
     
     - Parameters:
        - view: View to scroll to
        - animated: Show use animation
     */
    func scrollToView(view: UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x: 0, y: childStartPoint.y - 10, width: 1, height: self.frame.height), animated: animated)
        }
    }
    
    /**
     Scroll to top
     
     - Parameters:
        - animated: Show use animation
     */
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    /**
     Scroll to bottom
     
     - Parameters:
     - animated: Show use animation
     */
    func scrollToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if bottomOffset.y > 0 {
            setContentOffset(bottomOffset, animated: animated)
        }
    }
    
}
