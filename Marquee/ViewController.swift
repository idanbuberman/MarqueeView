//
//  ViewController.swift
//  Marquee
//
//  Created by Idan Buberman on 22/02/2018.
//  Copyright © 2018 Idan Buberman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var marqueeContainer: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = .orange
        let foo: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let koo: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let goo: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        foo.backgroundColor = .blue
        koo.backgroundColor = .red
        goo.backgroundColor = .green
        
        let marquee: MarqueeView = MarqueeView(frame: .zero, views: [foo,koo,goo], scrollDirection: .topToBottom)
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
}

enum ScrollDirectionEnum {
    case rightToLeft
    case leftToRight
    case topToBottom
    case bottomToTop
}

/// Marquee is based on stack view as main container for animations.
/// It has array of UIViews, displayed in the marquee according to user's animation prefrences.
/// Each UIView recieves self.bounds as his frame.
class MarqueeView: UILabel {
    
    /// Main UIStackView for displaying UIViews.
    private var marqueeStackview: UIStackView = UIStackView()
    private var arrViews: [UIView]
    
    /// Tells marquee animation direction, set by user.
    /// TODO: at the moment, it is only posible to give value only on init - change anchors
    private var scrollDirection: ScrollDirectionEnum
 
    //
    private enum axisEnum {
        case horizontal
        case vertical
    }
    
    //
    private var axis: axisEnum { return scrollDirection == .topToBottom || scrollDirection == .bottomToTop ? .vertical : .horizontal }

    private var displayDuration: TimeInterval
    private var animationDuration: TimeInterval
    
    //       ******************
    //MARK:- *** Life Cycle ***
    //       ******************
    init(frame: CGRect, views: [UIView] = [], scrollDirection: ScrollDirectionEnum = .rightToLeft, displayDuration: TimeInterval = 3.0 ,animationDuration: TimeInterval = 0.5) {
        self.arrViews = views
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
        guard arrViews.count > 0 else { return }
        
        marqueeStackview.addArrangedSubview(arrViews[0])
    }
    
    private func startScrolling() {
        guard arrViews.count > 0 else { return }
        _ = Timer.scheduledTimer(timeInterval: displayDuration + animationDuration, target: self, selector: #selector(action as () -> Void), userInfo: nil, repeats: true)
    }
    
    //       **************************
    //MARK:- *** Marquee animations ***
    //       **************************
    @objc func action() {
//        guard arrViews.count > 1 else { return }
        
        // Calculations:
        
        // View to remove: TTB -> bottom, BTT -> top, RTL -> left, LTR -> right
        let viewToRemove = previousDisplayedView()
        
        // Next view to display, is NOT dsiplayed, but will be in the next run...
        let viewToDisplay = nextViewToDisplay()
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.marqueeStackview.removeArrangedSubview(viewToRemove)
            self.marqueeStackview.addArrangedSubview(viewToDisplay)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        })
    }
    
    func nextViewToDisplay() -> UIView {
        switch scrollDirection {
        case .rightToLeft: return topArrangedLabel()
        case .leftToRight: return bottomArrangedLabel()
        case .bottomToTop: return topArrangedLabel()
        case .topToBottom: return bottomArrangedLabel()
        }
    }
    
    func previousDisplayedView() -> UIView {
        switch scrollDirection {
        case .rightToLeft: return topArrangedLabel()
        case .leftToRight: return bottomArrangedLabel()
        case .bottomToTop: return topArrangedLabel()
        case .topToBottom: return bottomArrangedLabel()
        }
    }
    
    func topArrangedLabel() -> UIView {
        let label = arrViews.first!
        self.arrViews.removeFirst()
        self.arrViews.append(label)
        return label
    }
    
    func bottomArrangedLabel() -> UIView {
        let label = self.arrViews.last!
        self.arrViews.removeLast()
        self.arrViews.insert(label, at: 0)
        return label
    }
    
}
