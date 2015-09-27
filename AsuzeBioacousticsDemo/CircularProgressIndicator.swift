//
//  CircularProgressIndicator.swift
//  Bioacoustics
//
//  Created by acr on 24/07/2015.
//  Copyright (c) 2015 University of Southampton. All rights reserved.
//

import UIKit

class CircularProgressIndicator : UIView {
    
    var percent:Double = 0
    
    func setProgress(percent: Double) {
        
        self.percent = percent
    
        setNeedsDisplay()
        
    }
    
    override func drawRect(rect: CGRect) {
    
        let width = rect.width
        let height = rect.height
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor.darkGrayColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.darkGrayColor().CGColor)

        CGContextSetLineWidth(context, 20.0)
        
        var x:CGFloat = 0
        var y:CGFloat = 0
        
        var startAngle = 0.0
        var angle = Int(360.0 * percent / 100.0)

        CGContextMoveToPoint(context, 0.5 * width, 0.1 * width)
        
        for i in -1...angle {
            x = width * (0.5 + 0.4 * CGFloat(sin(Double(i) / 180.0 * 3.14)))
            y = width * (0.5 - 0.4 * CGFloat(cos(Double(i) / 180.0 * 3.14)))
            CGContextAddLineToPoint(context, x, y)
        }

        CGContextStrokePath(context)

        CGContextSetFillColorWithColor(context, UIColor.lightGrayColor().CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)

        CGContextMoveToPoint(context, x, y)
        
        for i in angle...360 {
            x = width * (0.5 + 0.4 * CGFloat(sin(Double(i) / 180.0 * 3.14)))
            y = width * (0.5 - 0.4 * CGFloat(cos(Double(i) / 180.0 * 3.14)))
            CGContextAddLineToPoint(context, x, y)
        }

        CGContextStrokePath(context)

    }
    
}
