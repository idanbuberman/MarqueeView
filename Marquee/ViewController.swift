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
        
        let marquee: MarqueeView = MarqueeView(frame: .zero, dataSource: self, scrollDirection: .scrollingRight)
        marquee.dataSource = self
        marqueeContainer.addSubview(marquee)
        
        marquee.leadingAnchor.constraint(equalTo: marqueeContainer.leadingAnchor).isActive = true
        marquee.trailingAnchor.constraint(equalTo: marqueeContainer.trailingAnchor).isActive = true
        marquee.topAnchor.constraint(equalTo: marqueeContainer.topAnchor).isActive = true
        marquee.bottomAnchor.constraint(equalTo: marqueeContainer.bottomAnchor).isActive = true
        view.layoutIfNeeded()
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
        return nextView
    }
}
