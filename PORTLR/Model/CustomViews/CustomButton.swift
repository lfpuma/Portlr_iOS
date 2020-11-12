//
//  CustomButton.swift
//  Proenti
//
//  Created by Hunain on 17/01/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {
    
    @IBInspectable var cornarRadius:CGFloat = 0.0 {
        
        didSet {
            layer.cornerRadius = cornarRadius
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
    
    @IBInspectable var isUnderline:Bool = false {
        
        didSet {
            if isUnderline {
                guard let text = self.titleLabel?.text else { return }
                
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
                
                self.setAttributedTitle(attributedString, for: .normal)
            }
        }
    }
    
    @IBInspectable var isOval:Bool = false {
        
        didSet {
            if isOval {
                layer.cornerRadius  = self.frame.size.height/2
            }else{
                layer.cornerRadius = cornarRadius
            }
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        
        didSet {
            layer.borderWidth = borderWidth
            layer.borderColor = borderColor.cgColor
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
    
    
    // MARK: Setting button Title Appearance
    
    @IBInspectable var titleShadowColor: UIColor = UIColor.clear {
        
        didSet {
            self.titleLabel?.layer.shadowColor = titleShadowColor.cgColor
        }
    }
    
    @IBInspectable var titleLabelShadowOffset: CGSize = CGSize.zero {
        
        didSet {
            self.titleLabel?.layer.shadowOffset = titleLabelShadowOffset
        }
    }
    
    @IBInspectable var titleShadowOpacity: Float = 0.5 {
        
        didSet {
            
            self.titleLabel?.layer.shadowOpacity = titleShadowOpacity
        }
    }
    
    @IBInspectable var titleShadowRadius: CGFloat = 5.0 {
        
        didSet {
            self.titleLabel?.layer.shadowRadius = titleShadowRadius
        }
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        if isCircle {
            layer.cornerRadius  = self.frame.size.width/2
        }else if isOval {
            layer.cornerRadius  = self.frame.size.height/2
        }else{
            layer.cornerRadius = cornarRadius
        }
    }
}
