//
//  CustomTextView.swift
//  Proenti
//
//  Created by Hunain on 17/01/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

@IBDesignable class CustomTextView: KMPlaceholderTextView, UITableViewDelegate {

    @IBInspectable var cornarRadius:CGFloat = 0.0 {
        
        didSet {
            layer.cornerRadius = cornarRadius
        }
        
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        
        didSet {
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var isCircle:Bool = false {
        
        didSet {
            if isCircle {
                layer.cornerRadius  = self.frame.size.width/2
            }else{
                layer.cornerRadius = cornarRadius
            }
        }
    }
    
    @IBInspectable var bottomBorderColor: UIColor = UIColor.clear{
        
        didSet {
            let border          = CALayer()
            let width           = CGFloat(2.0)
            border.borderColor  = bottomBorderColor.cgColor
            border.frame        = CGRect(x: 0, y: self.frame.size.height - width, width:  UIScreen.main.bounds.size.width, height: self.frame.size.height)
            border.borderWidth  = width
            self.layer.sublayers?.removeFirst()
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.lightGray {
        
        didSet {
            layer.borderColor = borderColor.cgColor
            if borderWidth == 0 {borderWidth = 1.0}
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize.zero {
        
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.5 {
        
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 5.0 {
        
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    
    @IBInspectable var paddingTop: CGFloat = 0.0 {
        
        didSet {
            self.layoutSubviews()
        }
    }
    
    @IBInspectable var paddingLeft: CGFloat = 0.0 {
        
        didSet {
            self.layoutSubviews()
        }
    }
    
    @IBInspectable var paddingBottom: CGFloat = 0.0 {
        
        didSet {
            self.layoutSubviews()
        }
    }
    
    @IBInspectable var paddingRight: CGFloat = 0.0 {
        
        didSet {
            self.layoutSubviews()
        }
    }
    
    
    override var frame: CGRect {
        didSet {
            if isCircle {
                layer.cornerRadius  = self.frame.size.width/2
            }else{
                layer.cornerRadius = cornarRadius
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isCircle {
            layer.cornerRadius  = self.frame.size.width/2
        }else{
            layer.cornerRadius = cornarRadius
        }
        
        self.textContainerInset = UIEdgeInsets.init(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
    }
    
}
