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
        var label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        var label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        var label3 = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label1.text = "idan"
        label2.text = "rotem"
        label3.text = "hillel"
        label1.backgroundColor = .red
        label2.backgroundColor = .red
        label3.backgroundColor = .red
        
        let marquee: MarqueeView = MarqueeView(frame: .zero, labels: [label1,label2,label3], scrollDirection: .rightToLeft)
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

class MarqueeView: UILabel {
    
    /// Marquee is based on stack view as main container for the UILables/UIViews.
    /// self bounds is the frame of? size to fit to larger view? or uview gets self bounds.
    /// The stack view is larger than self because it holds in every given moment 3 labels/views with the middle view
    private var marqueeStackview: UIStackView = UIStackView()
    private var labels: [UILabel]
    
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
    
    //       ******************
    //MARK:- *** Life Cycle ***
    //       ******************
    convenience init() {
        self.init(frame: .zero)
    }
    
    init(frame: CGRect, labels: [UILabel] = [], scrollDirection: ScrollDirectionEnum = .rightToLeft) {
        self.labels = labels
        self.scrollDirection = scrollDirection
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if axis == .vertical {
            marqueeStackview.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            marqueeStackview.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            marqueeStackview.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            marqueeStackview.heightAnchor.constraint(equalToConstant: self.frame.height * 3).isActive = true
        } else {
            marqueeStackview.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            marqueeStackview.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            marqueeStackview.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            marqueeStackview.widthAnchor.constraint(equalToConstant: self.frame.width * 3).isActive = true
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
        setupLabels()
        startScrolling()
    }
    
    private func setupStackview() {
        marqueeStackview.axis = axis == .vertical ? .vertical : .horizontal
        marqueeStackview.distribution = .fillEqually
        marqueeStackview.alignment = .fill
        marqueeStackview.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(marqueeStackview)
    }
    
    private func setupLabels() {
        labels.forEach { element in marqueeStackview.addArrangedSubview(element) }
    }
    
    private func startScrolling() {
        let marqueeTimer: Timer! = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(action as () -> Void), userInfo: nil, repeats: true)
        print(marqueeTimer)
    }
    
    //       ******************
    //MARK:- *** Life ***
    //       ******************
    func labelToMove() -> UILabel {
        switch scrollDirection {
        case .rightToLeft: return topArragedLabel()
        case .leftToRight: return bottomArragedLabel()
        case .bottomToTop: return topArragedLabel()
        case .topToBottom: return bottomArragedLabel()
        }
    }
    
    func topArragedLabel() -> UILabel {
        let label = labels.first!
        self.labels.removeFirst()
        self.labels.append(label)
        return label
    }
    
    func bottomArragedLabel() -> UILabel {
        let label = self.labels.last!
        self.labels.removeLast()
        self.labels.insert(label, at: 0)
        return label
    }
    
    @objc func action() {
        let foo = labelToMove()
        UIView.animate(withDuration: 1, animations: {
            self.marqueeStackview.sendSubview(toBack: foo)
            self.marqueeStackview.removeArrangedSubview(foo)
            self.marqueeStackview.addArrangedSubview(foo)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        })
    }
}
