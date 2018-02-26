//
//  ViewController.swift
//  Marquee
//
//  Created by Idan Buberman on 22/02/2018.
//  Copyright © 2018 Idan Buberman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MarqueeViewDataSource {
    
    private var currentDisplayedIndex: Int = 0
    @IBOutlet var marqueeContainer: UIView!
    
    private var arrViews: [UIView] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = .orange
        let foo: UIView = UIView(frame: .zero)
        let koo: UIView = UIView(frame: .zero)
        let goo: UIView = UIView(frame: .zero)
        let roo: UIView = UIView(frame: .zero)
        foo.backgroundColor = .blue
        koo.backgroundColor = .red
        goo.backgroundColor = .green
        roo.backgroundColor = .magenta
        arrViews = [foo,koo,goo,roo]
        
        let marquee: MarqueeView = MarqueeView(frame: .zero, scrollDirection: .scrollingUp)
        marquee.dataSource = self
        marqueeContainer.addSubview(marquee)
        
        marquee.leadingAnchor.constraint(equalTo: marqueeContainer.leadingAnchor).isActive = true
        marquee.trailingAnchor.constraint(equalTo: marqueeContainer.trailingAnchor).isActive = true
        marquee.topAnchor.constraint(equalTo: marqueeContainer.topAnchor).isActive = true
        marquee.bottomAnchor.constraint(equalTo: marqueeContainer.bottomAnchor).isActive = true
        
        view.layoutIfNeeded()
        
        setupButton()
    }
    
    let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    private func setupButton() {
//        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(action), for: .touchUpInside)
        button.backgroundColor = .red
        
//        action()
    }
    
    private enum axisEnum {
        case horizontal
        case vertical
    }
    private var axis: axisEnum = .horizontal
    
    var leadingAnchor: NSLayoutConstraint!
    var trailingAnchor: NSLayoutConstraint!
    var topAnchor: NSLayoutConstraint!
    var bottomAnchor: NSLayoutConstraint!
    var widthAnchor: NSLayoutConstraint!
    var heightAnchor: NSLayoutConstraint!
    var centerXAnchor: NSLayoutConstraint!
    var centerYAnchor: NSLayoutConstraint!

    @objc func action() {
        leadingAnchor = button.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        trailingAnchor = button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        topAnchor = button.topAnchor.constraint(equalTo: view.topAnchor)
        bottomAnchor = button.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        widthAnchor = button.widthAnchor.constraint(equalToConstant: view.frame.width/2)
        heightAnchor = button.heightAnchor.constraint(equalToConstant: view.frame.height/2)
        centerXAnchor = button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        centerYAnchor = button.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        if axis == .vertical {
            leadingAnchor.isActive = true
            trailingAnchor.isActive = true
            centerYAnchor.isActive = true
            heightAnchor.isActive = true
            topAnchor.isActive = false
            bottomAnchor.isActive = false
            centerXAnchor.isActive = false
            widthAnchor.isActive = false
            axis = .horizontal
        } else {
            topAnchor.isActive = true
            bottomAnchor.isActive = true
            centerXAnchor.isActive = true
            widthAnchor.isActive = true
            leadingAnchor.isActive = false
            trailingAnchor.isActive = false
            centerYAnchor.isActive = false
            heightAnchor.isActive = false
            axis = .vertical
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    /**
     Returns the next UIView in views array according to managed index.
     This function is manages the index - once index is out of bouds, it will equate it to zero.
     
     - parameter marqueeView: Displaying MarqueeView.
     - parameter dequeuedView: Use this UIView reference to optimize memory and efficiancy.
     
     - returns: Next view in views array to display.
     */
    func nextViewToDisplay(_ marqueeView: MarqueeView, dequeuedView: UIView?) -> UIView {
        var nextView: UIView!
        if dequeuedView == nil {
            nextView = UIView()
        }
        if currentDisplayedIndex+1 > arrViews.count-1 {
            currentDisplayedIndex = 0
            nextView = arrViews[0]
        } else {
            currentDisplayedIndex += 1
            nextView = arrViews[currentDisplayedIndex]
        }
        return nextView
    }
}

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
    func nextViewToDisplay(_ marqueeView: MarqueeView, dequeuedView: UIView?) -> UIView
}

/// Marquee is based on stack view as main container for animations.
/// It has array of UIViews, displayed in the marquee according to user's animation prefrences.
/// Each UIView recieves self.bounds as his frame.
class MarqueeView: UIView {
    
    /// Main UIStackView for displaying UIViews.
    private var marqueeStackview: UIStackView = UIStackView()
    var dataSource: MarqueeViewDataSource?
    
    /// Tells marquee animation direction, set by user.
    /// TODO: at the moment, it is only posible to give value only on init - change anchors
    private var scrollDirection: ScrollDirectionEnum
    
    //
    private enum axisEnum {
        case horizontal
        case vertical
    }
    
    //
    private var axis: axisEnum { return scrollDirection == .scrollingUp || scrollDirection == .scrollingDown ? .vertical : .horizontal }

    private var displayDuration: TimeInterval
    private var animationDuration: TimeInterval
    
    //       ******************
    //MARK:- *** Life Cycle ***
    //       ******************
    init(frame: CGRect, views: [UIView] = [], scrollDirection: ScrollDirectionEnum = .scrollingRight, displayDuration: TimeInterval = 3.0 ,animationDuration: TimeInterval = 0.5) {
        self.scrollDirection = scrollDirection
        self.displayDuration = displayDuration
        self.animationDuration = animationDuration
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
        marqueeStackview.addArrangedSubview(UIView())
        marqueeStackview.addArrangedSubview(UIView())
        marqueeStackview.addArrangedSubview(UIView())
    }
    
    private func startScrolling() {
        _ = Timer.scheduledTimer(timeInterval: displayDuration + animationDuration, target: self, selector: #selector(action as () -> Void), userInfo: nil, repeats: true)
    }
    
    //       **************************
    //MARK:- *** Marquee animations ***
    //       **************************
    @objc func action() {
        guard let dataSource = dataSource else { return }
        
        // View to remove
        let viewToRemove = previousDisplayedView()
        
        // Next view to display, is NOT dsiplayed, but will be in the next run...
        let viewToDisplay = dataSource.nextViewToDisplay(self, dequeuedView: viewToRemove)
        viewToDisplay.alpha = 0
        
        UIView.animate(withDuration: animationDuration, animations: {
            if let viewToRemove = viewToRemove {
                self.marqueeStackview.removeArrangedSubview(viewToRemove)
            }
            self.marqueeStackview(addView: viewToDisplay)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }) { _ in
            viewToDisplay.alpha = 1
        }
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
    private func previousDisplayedView() -> UIView? {
        switch scrollDirection {
        case .scrollingRight,
             .scrollingDown: return marqueeStackview.arrangedSubviews.last
        case .scrollingLeft,
             .scrollingUp: return marqueeStackview.arrangedSubviews.first
        }
    }
}
