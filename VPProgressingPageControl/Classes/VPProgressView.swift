//
//  VPProgressView.swift
//  VPTimerPageControl
//
//  Created by Vinayak Parmar on 02/08/18.
//  Copyright © 2018 VMP. All rights reserved.
//

import UIKit

private let kAnimationKey = "animateProgress"

class VPProgressView: UIView, CAAnimationDelegate {
    
    // MARK: Outlets
    // MARK: Variables
    @IBInspectable var animateDuration: Double = 3 {
        didSet {
            animation.duration = animateDuration
        }
    }
    @IBInspectable var progressColor: UIColor = UIColor.red {
        didSet {
            progressLayer.backgroundColor = progressColor.cgColor
        }
    }
    let progressLayer =  CALayer()
    let animation = CABasicAnimation(keyPath: "bounds.size.width")
    var animationComplete : (()->())?
    var isProgressComplete: Bool {
        return progressLayer.frame.size.width == frame.size.width
    }
    
    // MARK: METHODS
    // MARK: Initialisers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicSetup()
    }

    // MARK: View lifecycle
    // MARK: Button click events
    // MARK: Helper mthods
    func basicSetup() {
        layer.addSublayer(progressLayer)
        progressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.size.width)
        progressLayer.position = CGPoint.zero
        progressLayer.anchorPoint = CGPoint.zero
        
        animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.duration = CFTimeInterval(animateDuration)
        animation.fromValue = progressLayer.frame.size.width
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
    }
    
    func startProgressLayer(shouldAnimate: Bool = true) {
        if progressLayer.frame.size.width == frame.size.width {
            if progressLayer.animation(forKey: kAnimationKey) == nil {
                return
            }
        }

        progressLayer.removeAnimation(forKey: kAnimationKey)
        if shouldAnimate {
            animation.fromValue = 0
            animation.toValue = bounds.size.width
            
            progressLayer.add(animation,
                              forKey: kAnimationKey)
        } else {
            
            CALayer.performWithoutAnimation { [weak self] in
                if let weakSelf = self {
                    weakSelf.progressLayer.frame.size = CGSize(width: frame.size.width,
                                                               height: frame.size.height)
                    weakSelf.progressLayer.setNeedsLayout()
                    weakSelf.progressLayer.layoutIfNeeded()
                }
            }            
        }
    }
    
    func resetProgress() {
        progressLayer.removeAnimation(forKey: kAnimationKey)
        CALayer.performWithoutAnimation { [weak self] in
            if let weakSelf = self {
                weakSelf.progressLayer.frame.size = CGSize(width: 0,
                                                           height: frame.size.height)
                weakSelf.progressLayer.setNeedsLayout()
                weakSelf.progressLayer.layoutIfNeeded()
            }
        }
    }
    
    // MARK: CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation,
                          finished flag: Bool) {
        if flag {
            progressLayer.frame.size = CGSize(width: frame.size.width,
                                              height: frame.size.height)
            animationComplete?()
        }
    }
}

extension CALayer {
    class func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void){
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        actionsWithoutAnimation()
        CATransaction.commit()
    }
}
