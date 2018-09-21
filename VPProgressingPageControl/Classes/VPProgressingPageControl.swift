//
//  VPProgressingPageControl.swift
//  VPTimerPageControl
//
//  Created by Vinayak Parmar on 02/08/18.
//  Copyright © 2018 VMP. All rights reserved.
//

import UIKit
public protocol VPProgressingPageControlDelegate: class {
    func pageProgressCompleteFor(page: Int)
}

open class VPProgressingPageControl: UIView {
    
    // MARK: Outlets
    // MARK: Variables
    @IBInspectable public var animateDuration: Double = 3.0 {
        didSet {
            collectionView.reloadData()
        }
    }
    @IBInspectable public var progressColor: UIColor = UIColor.red {
        didSet {
            collectionView.reloadData()
        }
    }
    @IBInspectable public var pageBackgroundColor: UIColor = UIColor.blue {
        didSet {
            collectionView.reloadData()
        }
    }    
    @IBInspectable public var numberOfPages: Int = 5 {
        didSet {
            recalculateCollectionViewLayouts()
            collectionView.reloadData()
            startAutoScroll()
        }
    }
    @IBInspectable public var pageSpacing: CGFloat = 5.0 {
        didSet {
            recalculateCollectionViewLayouts()
            collectionView.reloadData()
        }
    }
    private var collectionView: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout!
    public var shouldContinueProgressing = true
    weak public var delegate: VPProgressingPageControlDelegate?
    private var currentlySelectedPage: Int = 0
    
    // MARK: METHODS
    // MARK: Initialisers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        basicSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        basicSetup()
    }
    
    // MARK: View lifecycle
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        recalculateCollectionViewLayouts()
    }

    // MARK: Button click events
    // MARK: Helper mthods
    private func basicSetup() {
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero,
                                          collectionViewLayout: flowLayout)
        collectionView.isUserInteractionEnabled = false
        collectionView.register(UINib.init(nibName: VPPageControlCVC.identifier(),
                                           bundle: nil),
                                forCellWithReuseIdentifier: VPPageControlCVC.identifier())
        collectionView.dataSource = self
        collectionView.backgroundColor = backgroundColor
        collectionView.allowsMultipleSelection = true
        
        addSubview(collectionView)
    }
    
    private func recalculateCollectionViewLayouts() {
        let numberOfPagesFloat = CGFloat(numberOfPages)
        let pageWidth = (bounds.size.width - (numberOfPagesFloat - 1)  * pageSpacing) / numberOfPagesFloat
        flowLayout.itemSize = CGSize(width: pageWidth, height: frame.size.height)
        flowLayout.minimumLineSpacing = pageSpacing
    }
    
    public func startAutoScroll() {
        if numberOfPages > 0 {
            currentlySelectedPage = 0
            shouldContinueProgressing = true
            collectionView.selectItem(at: IndexPath(item: 0,
                                                    section: 0),
                                      animated: false,
                                      scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
        }
    }
    
   public func scrollTo(page: Int) {
        shouldContinueProgressing = false
        currentlySelectedPage = page
        
        for index in 0...page {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index,
                                                                   section: 0)) as? VPPageControlCVC {
                cell.completePageProgress()
            }
        }
        
        for index in (page + 1)..<numberOfPages {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VPPageControlCVC {
                cell.resetProgress()
            }
        }
    }
}

extension VPProgressingPageControl: UICollectionViewDataSource, VPPageControlCVCDelegate {
    // MARK: UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return numberOfPages
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VPPageControlCVC.identifier(),
                                                      for: indexPath) as! VPPageControlCVC
        cell.progressContentView.progressColor = progressColor
        cell.progressContentView.animateDuration = animateDuration
        cell.contentView.backgroundColor = pageBackgroundColor
        cell.delegate = self
                
        return cell
    }
    
    // MARK: VPPageControlCVCDelegate
    func progressAnimationComplete(cell: VPPageControlCVC) {
        if let pageNumber = collectionView.indexPath(for: cell)?.row,
            shouldContinueProgressing {
            if pageNumber != (numberOfPages - 1) {
                let nextPage = pageNumber + 1
                currentlySelectedPage = nextPage
                collectionView.selectItem(at: IndexPath(item: nextPage, section: 0),
                                          animated: false,
                                          scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                delegate?.pageProgressCompleteFor(page: nextPage)
            }
        }
    }
}
