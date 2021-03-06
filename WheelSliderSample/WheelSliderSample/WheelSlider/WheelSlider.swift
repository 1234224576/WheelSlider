//
//  WheelSlider.swift
//  WheelSliderSample
//
//  Created by 曽和修平 on 2015/10/31.
//  Copyright © 2015年 deeptoneworks. All rights reserved.
//

import UIKit

protocol WheelSliderDelegate{
    func updateSliderValue(value:Double,sender:WheelSlider) -> ()
}

public enum WSKnobLineCap{
    case WSLineCapButt
    case WSLineCapRound
    case WSLineCapSquare
    var getLineCapValue:String{
        switch self{
        case .WSLineCapButt:
            return kCALineCapButt
        case .WSLineCapRound:
            return kCALineCapRound
        case .WSLineCapSquare:
            return kCALineCapSquare
        }
    }
}

@IBDesignable
public class WheelSlider: UIView {
    
    private let wheelView:UIView
    
    private var beforePoint:Double = 0
    private var currentPoint:Double = 0{
        didSet{
            wheelView.layer.removeAllAnimations()
            wheelView.layer.addAnimation(nextAnimation(), forKey: "rotateAnimation")
            valueTextLayer?.string = "\(Int(calcCurrentValue()))"
            delegate?.updateSliderValue(calcCurrentValue(),sender: self)
            callback?(calcCurrentValue())
        }
    }
    private var beganTouchPosition = CGPointMake(0, 0)
    private var moveTouchPosition = CGPointMake(0, 0){
        didSet{
            calcCurrentPoint()
        }
    }
    
    private let backgroundLayer:CAShapeLayer = CAShapeLayer()
    private let knobLayer:CAShapeLayer = CAShapeLayer()
    private var valueTextLayer:CATextLayer?
    
    var delegate : WheelSliderDelegate?
    public var callback : ((Double) -> ())?
    
    //backgroundCircleParameter
    @IBInspectable public var backStrokeColor : UIColor = UIColor.darkGrayColor(){
        didSet{
            setStrokeColor(backgroundLayer, color: backStrokeColor)
        }
    }
    @IBInspectable public var backFillColor : UIColor = UIColor.darkGrayColor(){
        didSet{
            setFillColor(backgroundLayer, color: backFillColor)
        }
    }
    @IBInspectable public var backWidth : CGFloat = 10.0{
        didSet{
            setLayerWidth(backgroundLayer, width: backWidth)
        }
    }
    
    
    //knobParameter
    @IBInspectable public var knobStrokeColor : UIColor = UIColor.whiteColor(){
        didSet{
            setStrokeColor(knobLayer, color: knobStrokeColor)
        }
    }
    @IBInspectable public var knobWidth : CGFloat = 30.0{
        didSet{
            setLayerWidth(knobLayer, width: knobWidth)
        }
    }
    @IBInspectable public var knobLength : CGFloat = 0.025{
        didSet{
            setKnobLayerLength(knobLayer, len: knobLength)
        }
    }
    public var knobLineCap = WSKnobLineCap.WSLineCapRound{
        didSet{
            setKnobLayerLineCap(knobLayer, cap: knobLineCap)
        }
    }
    
    @IBInspectable public var maxVal:Int = 10
    @IBInspectable public var speed:Int = 40
    @IBInspectable public var isLimited:Bool = false
    @IBInspectable public var allowNegativeNumber:Bool = true
    @IBInspectable public var isValueText:Bool = false{
        didSet{
            if(isValueText){
                if let layer = drawValueText(){
                    valueTextLayer = layer
                    self.layer.addSublayer(layer)
                }
            }else{
                valueTextLayer?.foregroundColor = UIColor.clearColor().CGColor
            }
        }
    }
    @IBInspectable public var valueTextColor:UIColor = UIColor.whiteColor()
    @IBInspectable public var valueTextFontSize:CGFloat = 20.0
    public lazy var font:UIFont = UIFont.systemFontOfSize(self.valueTextFontSize)
    
    override init(frame: CGRect) {
        wheelView = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
        super.init(frame: frame)
        addSubview(wheelView)
        drawBackgroundCicle()
        drawPointerCircle()
        wheelView.layer.addSublayer(backgroundLayer)
        wheelView.layer.addSublayer(knobLayer)
    }

    required public init?(coder aDecoder: NSCoder) {
        wheelView = UIView();
        super.init(coder: aDecoder)
        wheelView.frame = bounds
        addSubview(wheelView)
        drawBackgroundCicle()
        drawPointerCircle()
        wheelView.layer.addSublayer(backgroundLayer)
        wheelView.layer.addSublayer(knobLayer)
    }
    
    private func drawValueText()->CATextLayer?{
        guard(isValueText)else{
            return nil
        }
        let textLayer = CATextLayer()
        textLayer.string = "\(0)"
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.frame = CGRectMake(wheelView.bounds.width/2 - valueTextFontSize, wheelView.frame.height/2 - valueTextFontSize/2.0, valueTextFontSize*2.0,valueTextFontSize*2.0)
        textLayer.foregroundColor = valueTextColor.CGColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.mainScreen().scale
        return textLayer
    }
    
    private func drawBackgroundCicle(){
        backgroundLayer.strokeColor = backStrokeColor.CGColor
        backgroundLayer.fillColor = backFillColor.CGColor
        backgroundLayer.lineWidth = backWidth
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let start = CGFloat(0)
        let end = CGFloat(2.0 * M_PI)
        backgroundLayer.path = UIBezierPath(arcCenter: center, radius: max(bounds.width, bounds.height) / 2, startAngle:start, endAngle: end ,clockwise: true).CGPath
        
    }
    private func drawPointerCircle(){
        knobLayer.strokeColor = knobStrokeColor.CGColor
        knobLayer.fillColor = UIColor.clearColor().CGColor
        knobLayer.lineWidth = knobWidth
        knobLayer.lineCap = knobLineCap.getLineCapValue
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let start = CGFloat(M_PI * 3.0/2.0)
        let end = CGFloat(M_PI * 3.0/2.0) + knobLength
        knobLayer.path = UIBezierPath(arcCenter: center, radius: max(bounds.width, bounds.height) / 2, startAngle:start, endAngle: end ,clockwise: true).CGPath
    }
    
    private func setStrokeColor(layer:CAShapeLayer,color:UIColor){
        layer.strokeColor = color.CGColor
    }
    private func setFillColor(layer:CAShapeLayer,color:UIColor){
        layer.fillColor = color.CGColor
    }
    private func setLayerWidth(layer:CAShapeLayer,width:CGFloat){
        layer.lineWidth = width
    }
    private func setKnobLayerLength(layer:CAShapeLayer,len:CGFloat){
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let start = CGFloat(M_PI * 3.0/2.0)
        let end = CGFloat(M_PI * 3.0/2.0) + len
        layer.path = UIBezierPath(arcCenter: center, radius: max(bounds.width, bounds.height) / 2, startAngle:start, endAngle: end ,clockwise: true).CGPath
    }
    private func setKnobLayerLineCap(layer:CAShapeLayer,cap:WSKnobLineCap){
        layer.lineCap = cap.getLineCapValue
    }
//    private func 
    
    
    
    private func nextAnimation()->CABasicAnimation{
        let start = CGFloat(beforePoint/Double(speed) * M_PI)
        let end = CGFloat(currentPoint/Double(speed) * M_PI)
        let anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.duration = 0
        anim.repeatCount = 0
        anim.fromValue = start
        anim.toValue =  end
        anim.removedOnCompletion = false;
        anim.fillMode = kCAFillModeForwards;
        anim.removedOnCompletion = false
        return anim
    
    }
    
    private func calcCurrentValue() -> Double{
        let normalization = Double(maxVal) / Double(speed)
        let val = currentPoint*normalization/2.0
        if(isLimited && val > Double(maxVal)){
            beforePoint = 0
            currentPoint = 0
        }
        return val
    }
    
    private func calcCurrentPoint(){
        
        let displacementY = abs(beganTouchPosition.y - moveTouchPosition.y)
        let displacementX = abs(beganTouchPosition.x - moveTouchPosition.x)
        
        guard(max(displacementX,displacementY) > 1.0)else{
            return
        }
        guard(allowNegativeNumber || calcCurrentValue() > 0)else{
            currentPoint++
            return
        }
        
        let centerX = bounds.size.width/2.0
        let centerY = bounds.size.height/2.0
        beforePoint = currentPoint
        if(displacementX > displacementY){
            if(centerY > beganTouchPosition.y){
                if(moveTouchPosition.x >= beganTouchPosition.x){
                    currentPoint++
                }else{
                    currentPoint--
                }
            }else{
                if(moveTouchPosition.x > beganTouchPosition.x){
                    currentPoint--
                }else{
                    currentPoint++
                }
            }
        }else{
            if(centerX <= beganTouchPosition.x){
                if(moveTouchPosition.y >= beganTouchPosition.y){
                    currentPoint++
                }else{
                    currentPoint--
                }
            }else{
                if(moveTouchPosition.y > beganTouchPosition.y){
                    currentPoint--
                }else{
                    currentPoint++
                }
            }
        }
    }
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch?
        if let t = touch{
            let pos = t.locationInView(self)
            beganTouchPosition = moveTouchPosition
            moveTouchPosition = pos
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
