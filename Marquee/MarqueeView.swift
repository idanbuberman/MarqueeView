//
//  MarqueeView.swift
//  Marquee
//
//  Created by idanMacMini on 26/02/2018.
//  Copyright © 2018 Idan Buberman. All rights reserved.
//

import UIKit

enum ScrollDirectionEnum {
    case scrollingRight
    case scrollingLeft
    case scrollingUp
    case scrollingDown
}

protocol MarqueeViewDataSource {
    
    /**
     Returns the next UIView in views array according to managed index.
     This function is manages the index - once index is out of bouds, it will equate it to zero.
     
     - parameter marqueeView: Displaying MarqueeView.
     - parameter dequeuedView: Use this UIView reference to optimize memory and efficiancy.
     
     - returns: Next view in views array to display.
     */
    func nextViewToDisplay(_ marqueeView: MarqueeView, dequeuedView: UIView) -> UIView
}

/// Marquee is based on stack view as main container for animations.
/// It has array of UIViews, displayed in the marquee according to user's animation prefrences.
/// Each UIView recieves self.bounds as his frame.
class MarqueeView: UIView {
    
    var dataSource: MarqueeViewDataSource?
    
    /// Main UIStackView for displaying UIViews.
    private var marqueeStackview: UIStackView = UIStackView()
    
    /// Tells marquee animation direction, set by user.
    private var scrollDirection: ScrollDirectionEnum
    
    // Enum to determine marqueeStackview layout anchors.
    private enum axisEnum {
        case horizontal
        case vertical
    }
    
    // Determine marqueeStackview layout anchors.
    private var axis: axisEnum { return scrollDirection == .scrollingUp || scrollDirection == .scrollingDown ? .vertical : .horizontal }
    
    private var displayDuration: TimeInterval
    private var animationDuration: TimeInterval
    
    //       ******************
    //MARK:- *** Life Cycle ***
    //       ******************
    init(frame: CGRect, dataSource: MarqueeViewDataSource? = nil, scrollDirection: ScrollDirectionEnum = .scrollingRight, displayDuration: TimeInterval = 3.0 ,animationDuration: TimeInterval = 0.5) {
        self.scrollDirection = scrollDirection
        self.displayDuration = displayDuration
        self.animationDuration = animationDuration
        self.dataSource = dataSource
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // For animations reasons, stack view is larger than self width or height (according to axis) 3 times - displayed view, next view to display and dummy view for animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if axis == .vertical {
            marqueeStackview.leadingAnchor.constraint   (equalTo: self.leadingAnchor)           .isActive = true
            marqueeStackview.trailingAnchor.constraint  (equalTo: self.trailingAnchor)          .isActive = true
            marqueeStackview.centerYAnchor.constraint   (equalTo: self.centerYAnchor)           .isActive = true
            marqueeStackview.heightAnchor.constraint    (equalToConstant: self.frame.height * 3).isActive = true
        } else {
            marqueeStackview.topAnchor.constraint       (equalTo: self.topAnchor)               .isActive = true
            marqueeStackview.bottomAnchor.constraint    (equalTo: self.bottomAnchor)            .isActive = true
            marqueeStackview.centerXAnchor.constraint   (equalTo: self.centerXAnchor)           .isActive = true
            marqueeStackview.widthAnchor.constraint     (equalToConstant: self.frame.width * 3) .isActive = true
        }
        layoutIfNeeded()
    }
    
    //       ****************
    //MARK:- *** Setup UI ***
    //       ****************
    private func commonInit() {
        backgroundColor = .clear
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        setupStackview()
        setupViews()
        startScrolling()
    }
    
    private func setupStackview() {
        marqueeStackview.axis = axis == .vertical ? .vertical : .horizontal
        marqueeStackview.distribution = .fillEqually
        marqueeStackview.alignment = .fill
        marqueeStackview.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(marqueeStackview)
    }
    
    private func setupViews() {
        switch scrollDirection {
        case .scrollingRight,
             .scrollingDown:
            marqueeStackview.addArrangedSubview(dataSource?.nextViewToDisplay(self, dequeuedView: UIView()) ?? UIView(frame: .zero))
            marqueeStackview.addArrangedSubview(dataSource?.nextViewToDisplay(self, dequeuedView: UIView()) ?? UIView(frame: .zero))
            marqueeStackview.addArrangedSubview(UIView())
        case .scrollingLeft,
             .scrollingUp:
            marqueeStackview.addArrangedSubview(UIView())
            marqueeStackview.addArrangedSubview(dataSource?.nextViewToDisplay(self, dequeuedView: UIView()) ?? UIView(frame: .zero))
            marqueeStackview.addArrangedSubview(dataSource?.nextViewToDisplay(self, dequeuedView: UIView()) ?? UIView(frame: .zero))
        }
    }
    
    private func startScrolling() {
        _ = Timer.scheduledTimer(timeInterval: displayDuration + animationDuration, target: self, selector: #selector(action as () -> Void), userInfo: nil, repeats: true)
    }
    
    //       **************************
    //MARK:- *** Marquee animations ***
    //       **************************
    
    @objc private func action() {
        guard let dataSource = dataSource else { return } // With no data source we are not able to present views andanimate the marquee
        
        // View to remove.
        let viewToRemove = previousDisplayedView()
        
        // Next view to display, is NOT dsiplayed, but will be in the next run...
        let viewToDisplay = dataSource.nextViewToDisplay(self, dequeuedView: viewToRemove)
        
        // In order to bypass animated add/remove to stack view.
        viewToRemove.alpha = 0
        viewToDisplay.alpha = 0
        
//        UIView.animate(withDuration: animationDuration, animations: {
//            self.marqueeStackview.removeArrangedSubview(viewToRemove)
//            self.marqueeStackview(addView: viewToDisplay)
//            self.setNeedsLayout()
//            self.layoutIfNeeded()
//        }) { _ in
//            viewToDisplay.alpha = 1
//        }
        
        /* Do Animations */
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        
        // View animations
        UIView.animate(withDuration: 2.0, animations: {
            self.marqueeStackview.removeArrangedSubview(viewToRemove)
            self.marqueeStackview(addView: viewToDisplay)
//            self.setNeedsLayout()
            self.layoutIfNeeded()
        }) { _ in
            viewToDisplay.alpha = 1
        }
        
        // Layer animations
//        let cornerAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.cornerRadius))
//        cornerAnimation.fromValue = oldValue
//        cornerAnimation.toValue = newButtonWidth/2
//
//        styledButton.layer.cornerRadius = newButtonWidth/2
//        styledButton.layer.add(cornerAnimation, forKey: #keyPath(CALayer.cornerRadius))
//
        CATransaction.commit()
    }
    
    /**
     Adding view to marquee stack according to scrolling direction.
     
     - parameter view: Added UIView.
     - parameter scrollingDirection: Scrolling direction.
     */
    private func marqueeStackview(addView view: UIView) {
        switch scrollDirection {
        case .scrollingRight,
             .scrollingDown: self.marqueeStackview.insertArrangedSubview(view, at: 0)
        case .scrollingLeft,
             .scrollingUp: self.marqueeStackview.addArrangedSubview(view)
        }
    }
    
    /**
     Removing view from marquee stack according to scrolling direction.
     This UIView is either previously displayed or is a dummy view used for the first iteration.
     
     - returns: UIView to remove from stack view.
     */
    private func previousDisplayedView() -> UIView {
        switch scrollDirection {
        case .scrollingRight,
             .scrollingDown: return marqueeStackview.arrangedSubviews.last!
        case .scrollingLeft,
             .scrollingUp: return marqueeStackview.arrangedSubviews.first!
        }
    }
}
