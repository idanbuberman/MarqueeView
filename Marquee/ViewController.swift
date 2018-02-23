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
        
        let marquee: MarqueeView = MarqueeView()
        marqueeContainer.addSubview(marquee)
        
        marquee.leadingAnchor.constraint(equalTo: marqueeContainer.leadingAnchor).isActive = true
        marquee.trailingAnchor.constraint(equalTo: marqueeContainer.trailingAnchor).isActive = true
        marquee.topAnchor.constraint(equalTo: marqueeContainer.topAnchor).isActive = true
        marquee.bottomAnchor.constraint(equalTo: marqueeContainer.bottomAnchor).isActive = true
        
        view.layoutIfNeeded()
    }
}

enum ScrollDirectionEnum {
    case rightToLeft
    case leftToRight
    case topToBottom
    case bottomToTop
}

class MarqueeView: UIView {
 
    enum axisEnum {
        case horizontal
        case vertical
    }
    
    var axis: axisEnum { return scrollDirection == .topToBottom || scrollDirection == .bottomToTop ? .vertical : .horizontal }
    var scrollDirection: ScrollDirectionEnum = .leftToRight
    var marqueeStackview: UIStackView!
    
    lazy var labels: [UILabel] = {
        let label1 = UILabel()
        label1.text = "label1"
        label1.textAlignment = .center
        label1.backgroundColor = .white
        label1.layer.cornerRadius = 5.0
        
        let label2 = UILabel()
        label2.text = "label2"
        label2.textAlignment = .center
        label2.backgroundColor = .green
        
        let label3 = UILabel()
        label3.text = "label3"
        label3.textAlignment = .center
        label3.backgroundColor = .purple
        
        return [label1, label2, label3]
    }()
    
    //MARK:- 
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        setupStackview()
        setupLabels()
        setupButtons()
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
    
    private func setupStackview() {
        marqueeStackview = UIStackView()
        
        marqueeStackview.axis = axis == .vertical ? .vertical : .horizontal
        marqueeStackview.distribution = .fillEqually
        marqueeStackview.alignment = .fill
        marqueeStackview.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(marqueeStackview)
    }
    
    func setupLabels() {
        labels.forEach { element in marqueeStackview.addArrangedSubview(element) }
    }
    
    func setupButtons() {
        let marqueeTimer: Timer! = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(action as () -> Void), userInfo: nil, repeats: true)
        print(marqueeTimer)
    }
    
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
