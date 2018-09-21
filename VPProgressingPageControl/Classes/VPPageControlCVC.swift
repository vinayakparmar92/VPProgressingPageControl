//
//  VPPageControlCVC.swift
//  VPTimerPageControl
//
//  Created by Vinayak Parmar on 02/08/18.
//  Copyright © 2018 VMP. All rights reserved.
//

import UIKit

protocol VPPageControlCVCDelegate: class {
    func progressAnimationComplete(cell: VPPageControlCVC)
}

class VPPageControlCVC: UICollectionViewCell {

    // MARK: Outlets
    @IBOutlet weak var progressContentView: VPProgressView!
    
    // MARK: Variables
    weak var delegate: VPPageControlCVCDelegate?
    var isProgressComplete: Bool {
        return progressContentView.isProgressComplete
    }
    
    // MARK: METHODS
    // MARK: Initialisers
    // MARK: View lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    
        progressContentView.animationComplete = {[weak self] in
            if let weakSelf = self {
                weakSelf.delegate?.progressAnimationComplete(cell: weakSelf)
            }
        }
        layer.cornerRadius = 1.5
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()        
    }
    
    // MARK: Button click events
    // MARK: Helper mthods
    func completePageProgress() {
        progressContentView.startProgressLayer(shouldAnimate: false)
    }
    
    func resetProgress() {
        progressContentView.resetProgress()
    }
    
    class func identifier() -> String {
        return "VPPageControlCVC"
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                progressContentView.startProgressLayer()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        progressContentView.resetProgress()
    }
}
