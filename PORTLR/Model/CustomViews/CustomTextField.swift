//
//  CustomTextField.swift
//  Proenti
//
//  Created by Hunain on 17/01/2019.
//  Copyright © 2019 Ranksol. All rights reserved.
//

import UIKit


@IBDesignable class CustomTextField: UITextField {    

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
            let width           = CGFloat(0.5)
            border.borderColor  = bottomBorderColor.cgColor
            border.frame        = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
            border.borderWidth  = self.frame.size.width
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
    
    @IBInspectable var placeholderColor:UIColor = UIColor.lightGray {
        
        didSet {
            if (self.placeholder?.count)! > 0 {
                self.attributedPlaceholder  = NSAttributedString(string: self.placeholder!,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
            }
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

    
    @IBInspectable var isCompulsory: Bool = false {
        didSet{
            
        }
    }
    
    @IBInspectable var errorMessage: String = "" {
        didSet{
        }
    }
    
    @IBInspectable var backgroundImage: UIImage? {
        didSet {
            self.updateFieldBackgroundView()
        }
    }
    
    func updateFieldBackgroundView() {
        if let img = backgroundImage {
            let iconView = UIImageView(frame: self.bounds)
            iconView.image = img
            self.addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.leadingAnchor.constraint(equalTo: iconView.superview!.leadingAnchor, constant: 0).isActive = true
            iconView.trailingAnchor.constraint(equalTo: iconView.superview!.trailingAnchor, constant: 0).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            self.updateFieldView()
        }
    }
    
    func updateFieldView() {
        if let image = leftImage {
            let iconView = UIImageView(frame:
                CGRect(x: 25, y: 0, width: 14, height: 20))
            iconView.contentMode = UIView.ContentMode.scaleAspectFit
            iconView.image = image
            let iconContainerView: UIView = UIView(frame:
                CGRect(x: 0, y: 15, width: 39, height: 20))
            iconContainerView.addSubview(iconView)
            leftView = iconContainerView
            leftViewMode = .always
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
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
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        return bounds.inset(by: padding)
    }

}
