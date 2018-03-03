//
//  ViewController.swift
//  Marquee
//
//  Created by Idan Buberman on 22/02/2018.
//  Copyright © 2018 Idan Buberman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var currentDisplayedIndex: Int = 0
    @IBOutlet var marqueeContainer: UIView!
    
    private var arrViews: [UIView] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        
        let marquee: MarqueeView = MarqueeView(frame: .zero, dataSource: self, scrollDirection: .scrollingUp)
        marquee.dataSource = self
        marqueeContainer.addSubview(marquee)
        
        marquee.leadingAnchor.constraint(equalTo: marqueeContainer.leadingAnchor).isActive = true
        marquee.trailingAnchor.constraint(equalTo: marqueeContainer.trailingAnchor).isActive = true
        marquee.topAnchor.constraint(equalTo: marqueeContainer.topAnchor).isActive = true
        marquee.bottomAnchor.constraint(equalTo: marqueeContainer.bottomAnchor).isActive = true
        view.layoutIfNeeded()
    }
    
    func setupViews() {
        
        let line: UIStackView = UIStackView()
        line.axis = .horizontal
        line.alignment = .fill
        line.distribution = .fillEqually
        
        let label: UILabel = UILabel()
        let label1: UILabel = UILabel()
        let label2: UILabel = UILabel()
        
        label.backgroundColor = .blue
        label1.backgroundColor = .red
        label2.backgroundColor = .green
        
        label.text = "idan"
        label1.text = "noah"
        label2.text = "rotem"
        
        line.addArrangedSubview(label)
        line.addArrangedSubview(label1)
        line.addArrangedSubview(label2)
        
        let line1: UIStackView = UIStackView()
        line1.axis = .horizontal
        line1.alignment = .fill
        line1.distribution = .fillEqually
        
        let label3: UILabel = UILabel()
        let label4: UILabel = UILabel()
        let label5: UILabel = UILabel()
        
        label3.backgroundColor = .blue
        label4.backgroundColor = .red
        label5.backgroundColor = .green
        
        label3.text = "ben"
        label4.text = "liam"
        label5.text = "liv"
        
        line1.addArrangedSubview(label3)
        line1.addArrangedSubview(label4)
        line1.addArrangedSubview(label5)
        
        let line2: UIStackView = UIStackView()
        line2.axis = .horizontal
        line2.alignment = .fill
        line2.distribution = .fillEqually
        
        let label6: UILabel = UILabel()
        let label7: UILabel = UILabel()
        let label8: UILabel = UILabel()
        
        label6.backgroundColor = .blue
        label7.backgroundColor = .red
        label8.backgroundColor = .green
        
        label6.text = "adi"
        label7.text = "sefi"
        label8.text = "mor"
        
        line2.addArrangedSubview(label6)
        line2.addArrangedSubview(label7)
        line2.addArrangedSubview(label8)
        arrViews = [line, line1, line2]
//        let foo: UIView = UIView(frame: .zero)
//        let koo: UIView = UIView(frame: .zero)
//        let goo: UIView = UIView(frame: .zero)
//        let roo: UIView = UIView(frame: .zero)
//        foo.backgroundColor = .blue
//        koo.backgroundColor = .red
//        goo.backgroundColor = .green
//        roo.backgroundColor = .magenta
//        arrViews = [foo,koo,goo,roo]
    }
}

extension ViewController: MarqueeViewDataSource {

    /**
     Returns the next UIView in views array according to managed index.
     This function is manages the index - once index is out of bouds, it will equate it to zero.
     
     - parameter marqueeView: Displaying MarqueeView.
     - parameter dequeuedView: Use this UIView reference to optimize memory and efficiancy.
     
     - returns: Next view in views array to display.
     */
    func nextViewToDisplay(_ marqueeView: MarqueeView, dequeuedView: UIView) -> UIView {
        var nextView = dequeuedView
        if currentDisplayedIndex+1 > arrViews.count-1 {
            currentDisplayedIndex = 0
            nextView = arrViews[0]
        } else {
            currentDisplayedIndex += 1
            nextView = arrViews[currentDisplayedIndex]
        }
        print(nextView)
        return nextView
    }
}
