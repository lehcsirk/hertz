//
//  ViewController.swift
//  hertz
//
//  Created by Cameron Krischel on 2/18/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import UIKit
import AVFoundation

var octave = 0
var isReady = true
var heldDown = true
var currentMode = "Hold"
var isPlaying = false

class ViewController: UIViewController
{
    var engineArray = [AVAudioEngine]()
    var toneArray = [AVTonePlayerUnit]()
    
//    var engine: AVAudioEngine!
//    var tone: AVTonePlayerUnit!
    
    let screenSize: CGRect = UIScreen.main.bounds
    var buttonWidth = 0.0
    var currentSpeed = 2
    
    var currentNote = ""
    var timer2 = Timer()
//    var buttonsArray = [UIButton]()
    var labelsArray = [UILabel]()
    
    var noteNameArray = ["C","C♯/D♭", "D", "D♯/E♭", "E", "F", "F♯/G♭", "G", "G♯/A♭", "A", "A♯/B♭", "B"]

    var myLabelArrayOfOne = [UILabel]()
    var label = UILabel()
    var divideLabel = UILabel()
    
    var toggleMode = UIButton()
    var freq = 0.0

    var segmentAngle = CGFloat()
    var center = CGPoint()
    var radius = CGFloat()
    var lineWidth = CGFloat()
    var gapSize = CGFloat()
    var circleLayerArray = [CAShapeLayer]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //===================================================================================//
//        tone = AVTonePlayerUnit()
//        tone.frequency = freq
//        tone.volume = 3.0
        
        
//        let format = AVAudioFormat(standardFormatWithSampleRate: tone.sampleRate, channels: 1)
//        engine = AVAudioEngine()
//        engine.attach(tone)
//        let mixer = engine.mainMixerNode
//        engine.connect(tone, to: mixer, format: format)
        
        setupToneAndEngine()
        
        //===================================================================================//

        let textSize = CGFloat(screenSize.width/8.28)
        let fontName = "Cambria"
        let buttonFont = UIFont(name: fontName, size: textSize)
        let octaveFont = UIFont(name: fontName, size: textSize*1.5)
        let toggleFont = UIFont(name: fontName, size: textSize*0.8)
        
        toggleMode = UIButton(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.width/4))
        toggleMode.center = CGPoint(x: screenSize.width/2, y: screenSize.height*7/8)
        toggleMode.layer.borderColor = UIColor.white.cgColor
        toggleMode.layer.borderWidth = 1.0
        toggleMode.titleLabel?.textAlignment = .center
        toggleMode.titleLabel?.font = toggleFont
        toggleMode.titleLabel?.allowsDefaultTighteningForTruncation = false
        toggleMode.titleLabel?.adjustsFontSizeToFitWidth = false
        toggleMode.titleLabel?.numberOfLines = 2
        toggleMode.setTitleColor(UIColor.white, for: .normal)
        toggleMode.setTitle("Toggle\nMode: \(currentMode)", for: .normal)
        toggleMode.backgroundColor = UIColor.black
        toggleMode.layer.zPosition = 2
        toggleMode.addTarget(self, action: #selector(modeChange), for: .touchDown)
        self.view.addSubview(toggleMode)
        
        buttonWidth = Double(screenSize.height*0.0869565217)

        self.view.isMultipleTouchEnabled = false
        self.view.isExclusiveTouch = true
        self.view.backgroundColor = .clear

        // Colors
        let lightGray = UIColor(red:216/255,  green:216/255,  blue:216/255, alpha:1)
        let topColor = UIColor(red: 7/255, green: 239/255, blue: 235/255, alpha: 1.0)
        let botColor = UIColor(red: 102/255, green: 68/255, blue: 175/255, alpha: 1.0)
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor.cgColor, botColor.cgColor]
        gradientLayer.zPosition = -1
        self.view.layer.addSublayer(gradientLayer)
        
        segmentAngle = CGFloat(2*Double.pi/12)
        center = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        radius = screenSize.height*0.225
        if(radius > screenSize.width*0.4)
        {
            radius = screenSize.width*0.4
        }
        
        lineWidth = round(radius/4.03902439)
        gapSize = 0.03
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width/2, height: screenSize.width/4))
        label.center = CGPoint(x: screenSize.width/2, y: screenSize.height/8)
        label.textAlignment = .center
        label.text = "8ve: 4"
        label.font = octaveFont
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = UIColor.clear
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 10.0
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.masksToBounds = false
        self.view.addSubview(label)
        myLabelArrayOfOne.insert(label, at: 0)
        label.isHidden = false
        
        let circleLayer = CAShapeLayer()
        circleLayer.zPosition = 2
        circleLayer.lineWidth = lineWidth/4.1
        circleLayer.path = UIBezierPath(arcCenter: center, radius: radius-lineWidth-2.75*circleLayer.lineWidth, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true).cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        self.view.layer.insertSublayer(circleLayer, at: 1)
        
        let circleLayer2 = CAShapeLayer()
        circleLayer2.zPosition = 2
        circleLayer2.lineWidth = lineWidth/4.1
        circleLayer2.path = UIBezierPath(arcCenter: center, radius: radius+lineWidth/2+0.75*circleLayer.lineWidth, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true).cgPath
        circleLayer2.strokeColor = UIColor.white.cgColor
        circleLayer2.fillColor = UIColor.clear.cgColor
        self.view.layer.insertSublayer(circleLayer2, at: 1)
        
        // Octave buttons!
        let upButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        upButton.layer.zPosition = 2
        upButton.center.x = screenSize.width/2
        upButton.center.y = screenSize.height/2 - CGFloat(buttonWidth*0.6)
        upButton.backgroundColor = UIColor.clear//init(red: 0, green: 0, blue: 200, alpha: 1)
        upButton.layer.cornerRadius = upButton.frame.size.width/2
        upButton.layer.borderWidth = 1
        upButton.layer.borderColor = UIColor.red.cgColor
        upButton.setTitle("8va", for: .normal)
        upButton.setTitleColor(UIColor.white, for: .normal)
        upButton.titleLabel!.font =  buttonFont
        upButton.titleLabel!.numberOfLines = 2
        upButton.titleLabel?.minimumScaleFactor = 0.0001
        upButton.titleLabel?.adjustsFontSizeToFitWidth = true
        upButton.titleLabel?.numberOfLines = 2
        upButton.titleLabel!.baselineAdjustment = .alignCenters
        upButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        view.addSubview(upButton)
//        buttonsArray.append(upButton)
        upButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        upButton.addTarget(self, action: #selector(upOctave), for: .touchUpInside)
        
        // Octave buttons!
        let downButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        downButton.layer.zPosition = 2
        downButton.center.x = screenSize.width/2
        downButton.center.y = screenSize.height/2 + CGFloat(buttonWidth*0.6)
        downButton.backgroundColor = UIColor.clear//init(red: 0, green: 0, blue: 200, alpha: 1)
        downButton.layer.cornerRadius = downButton.frame.size.width/2
        downButton.layer.borderWidth = 1
        downButton.layer.borderColor = UIColor.red.cgColor
        downButton.setTitle("8vb", for: .normal)
        downButton.setTitleColor(UIColor.white, for: .normal)
        downButton.titleLabel!.font =  buttonFont
        downButton.titleLabel!.numberOfLines = 2
        downButton.titleLabel?.minimumScaleFactor = 0.0001
        downButton.titleLabel?.adjustsFontSizeToFitWidth = true
        downButton.titleLabel?.numberOfLines = 2
        downButton.titleLabel!.baselineAdjustment = .alignCenters
        downButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        view.addSubview(downButton)
//        buttonsArray.append(downButton)
        downButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        downButton.addTarget(self, action: #selector(downOctave), for: .touchUpInside)
        
        // Divider Line
        divideLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 2*(radius-lineWidth-2.75*circleLayer.lineWidth), height: circleLayer.lineWidth))
        divideLabel.center = CGPoint(x: screenSize.width/2, y: screenSize.height/2)
        divideLabel.textAlignment = .center
        divideLabel.backgroundColor = UIColor.white
        divideLabel.layer.zPosition = -1
        self.view.addSubview(divideLabel)
        
        for i in 0...11
        {
            let circleLayer = CAShapeLayer()
            circleLayer.lineWidth = lineWidth*2
            circleLayer.path = UIBezierPath(arcCenter: center, radius: round(radius-lineWidth/2), startAngle: CGFloat(segmentAngle * CGFloat(i)) + gapSize/2 - CGFloat(Double.pi/2), endAngle: CGFloat(segmentAngle * CGFloat(i+1) - gapSize/2) - CGFloat(Double.pi/2), clockwise: true).cgPath
            
            circleLayer.strokeColor = UIColor.black.cgColor
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.zPosition = 3
            // add the segment to the segments array and to the view
            self.view.layer.insertSublayer(circleLayer, at: 1)
            circleLayerArray.append(circleLayer)
            circleLayer.name = String(i)
            
            let button = UILabel(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
            button.layer.zPosition = 4
            button.backgroundColor = UIColor.clear//init(red: 0, green: 0, blue: 200, alpha: 1)
            button.layer.cornerRadius = button.frame.size.width/2
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.red.cgColor
            button.text = noteNameArray[i]
            button.textColor = UIColor.white
            button.font =  buttonFont
            button.numberOfLines = 2
            button.minimumScaleFactor = 0.0001
            button.adjustsFontSizeToFitWidth = true
            button.textAlignment = .center
            button.baselineAdjustment = .alignCenters
            button.lineBreakMode = NSLineBreakMode.byClipping
            view.addSubview(button)
            labelsArray.append(button)
            
            button.center.x = screenSize.width/2 + cos(CGFloat((segmentAngle) * CGFloat(i)) - CGFloat(Double.pi/2) + CGFloat(segmentAngle/2)) * (radius - CGFloat(buttonWidth/4))
            button.center.y = screenSize.height/2 + sin(CGFloat((segmentAngle) * CGFloat(i)) - CGFloat(Double.pi/2) + CGFloat(segmentAngle/2)) * (radius - CGFloat(buttonWidth/4))
            
            drawTriangle()
        }
    }
    @objc func updateLabel()
    {
        label.text = "8ve: " + String(octave + 4)
    }
    func drawTriangle()
    {
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: screenSize.width/2, y: screenSize.height/2 - CGFloat(buttonWidth*1.2)))
        trianglePath.addLine(to: CGPoint(x: screenSize.width/2 - CGFloat(buttonWidth), y: screenSize.height/2 - CGFloat(buttonWidth*0.25)))
        trianglePath.addLine(to: CGPoint(x: screenSize.width/2 + CGFloat(buttonWidth), y: screenSize.height/2 - CGFloat(buttonWidth*0.25)))
        trianglePath.close()

        let triangleLayer = CAShapeLayer()
        triangleLayer.path = trianglePath.cgPath
        triangleLayer.fillColor = UIColor.black.cgColor
        triangleLayer.strokeColor = UIColor(red: 200/255, green: 200/255, blue: 255/255, alpha: 1.0).cgColor
        triangleLayer.lineWidth = 5
        self.view.layer.addSublayer(triangleLayer)
        
        let trianglePath2 = UIBezierPath()
        trianglePath2.move(to: CGPoint(x: screenSize.width/2, y: screenSize.height/2 + CGFloat(buttonWidth*1.2)))
        trianglePath2.addLine(to: CGPoint(x: screenSize.width/2 - CGFloat(buttonWidth), y: screenSize.height/2 + CGFloat(buttonWidth*0.25)))
        trianglePath2.addLine(to: CGPoint(x: screenSize.width/2 + CGFloat(buttonWidth), y: screenSize.height/2 + CGFloat(buttonWidth*0.25)))
        trianglePath2.close()
        
        let triangleLayer2 = CAShapeLayer()
        triangleLayer2.path = trianglePath2.cgPath
        triangleLayer2.fillColor = UIColor.black.cgColor
        triangleLayer2.strokeColor = UIColor(red: 255/255, green: 200/255, blue: 200/255, alpha: 1.0).cgColor
        triangleLayer2.lineWidth = 5
        self.view.layer.addSublayer(triangleLayer2)
    }
    @objc func modeChange()
    {
        if(currentMode == "Hold")
        {
            currentMode = "Tap"
        }
        else
        {
            currentMode = "Hold"
        }
        toggleMode.setTitle("Toggle\nMode: \(currentMode)", for: .normal)
        print(currentMode)
    }
    @objc func upOctave()
    {
        if(octave < 1)
        {
            octave += 1
            print("Octave Up!")
            print("Current Octave: " + String(octave))
        }
        else
        {
            print("Too high")
        }
        updateLabel()
    }
    @objc func downOctave()
    {
        if(octave > -1)
        {
            octave -= 1
            print("Octave Down!")
            print("Current Octave: " + String(octave))
        }
        else
        {
            print("Too low")
        }
        updateLabel()
    }
    func setupToneAndEngine()
    {
        print("Setting up tone and engine")
        print("Engine array count: \(engineArray.count)")
        print("Tone array count: \(toneArray.count)")
        
        if(toneArray.count > 0)
        {
            if(toneArray.first!.isPlaying)
            {
                DispatchQueue.main.async {
                    self.toneArray.first?.stop()
                    self.toneArray.removeAll()
                }
            }
        }
        engineArray.first?.stop()
        engineArray.removeAll()
        print("Zoop")
        
        let myTone = AVTonePlayerUnit()
        myTone.frequency = freq
        myTone.volume = 3.0
        
        print("a")
        
        
        let format = AVAudioFormat(standardFormatWithSampleRate: myTone.sampleRate, channels: 1)
        print(format?.sampleRate ?? "format nil")
        
        print("b")
        
        let myEngine = AVAudioEngine()
        myEngine.attach(myTone)
        
        let mixer = (myEngine.mainMixerNode)
        
        print("c")
        
        myEngine.connect(myTone, to: mixer, format: format)
        do
        {
            try myEngine.start()
            print("d")
        }
        catch let error as NSError
        {
            print(error)
        }
        
        if(toneArray.count == 0)
        {
            print("Appended tone")
            toneArray.append(myTone)
        }
        else
        {
            print("Replaced tone")
            toneArray[0] = myTone
        }
        if(engineArray.count == 0)
        {
            print("Appended eng")
        }
        else
        {
            print("Replaced eng")
            engineArray[0] = myEngine
        }
        
        toneArray.append(myTone)
        engineArray.append(myEngine)
    }
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print("Touches moved")
        let touch = touches.first!
        let location = touch.location(in: self.view)
        var buttonPressed = false
        for i in 0...labelsArray.count - 1
        {
            if(labelsArray[i].frame.contains(location))
            {
                print("Location is contained at i: \(i)")
                buttonPressed = true

                circleLayerArray[i].lineWidth = lineWidth*2*1.3
                circleLayerArray[i].path = UIBezierPath(arcCenter: center, radius: round(radius-lineWidth/2), startAngle: CGFloat(segmentAngle * CGFloat(i)) + gapSize/2 - CGFloat(Double.pi/2), endAngle: CGFloat(segmentAngle * CGFloat(i+1) - gapSize/2) - CGFloat(Double.pi/2), clockwise: true).cgPath
                
                for k in 0...noteNameArray.count - 1
                {
                    if(labelsArray[i].text! == noteNameArray[k])
                    {
                        print("Found in array at k: \(k)")
                        if(freq == 261.625565 * pow(2.0, Double(k)/Double(12) + Double(octave)))
                        {
                            // Already playing this, don't stop
                            print("Already playing note")
                        }
                        else
                        {
                            print("New note")
//                             Switching tone, stop player and reset with new freq
//                            engine.mainMixerNode.volume = 0.0
//                            tone.stop()
//                            engine.reset()
                            
                            engineArray.last?.mainMixerNode.volume = 0.0
                            toneArray.last?.stop()
                            engineArray.last?.reset()

                            
                            freq = 261.625565 * pow(2.0, Double(i)/Double(12) + Double(octave))

                            engineArray.removeLast()
                            toneArray.removeLast()
                            
//                            tone.frequency = freq
//                            tone.preparePlaying()
//                            tone.play()
//                            engine.mainMixerNode.volume = 1.0
                            
                            setupToneAndEngine()
                            toneArray.last?.preparePlaying()
                            toneArray.last!.play()
                            engineArray.last?.mainMixerNode.volume = 1.0
                        }
                    }
                }
            }
            else
            {
                circleLayerArray[i].lineWidth = lineWidth*2
                circleLayerArray[i].path = UIBezierPath(arcCenter: center, radius: round(radius-lineWidth/2), startAngle: CGFloat(segmentAngle * CGFloat(i)) + gapSize/2 - CGFloat(Double.pi/2), endAngle: CGFloat(segmentAngle * CGFloat(i+1) - gapSize/2) - CGFloat(Double.pi/2), clockwise: true).cgPath
            }
        }
        if(!buttonPressed)
        {
            // Touch isn't in any button, stop playing
//            engine.mainMixerNode.volume = 0.0
//            tone.stop()
//            engine.reset()
            
            engineArray.last?.mainMixerNode.volume = 0.0
            toneArray.last!.stop()
            toneArray.removeLast()
            engineArray.last!.reset()
            engineArray.removeLast()
            setupToneAndEngine()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print("Touches ended")
        for m in 0...circleLayerArray.count - 1
        {
            circleLayerArray[m].lineWidth = lineWidth*2
            circleLayerArray[m].path = UIBezierPath(arcCenter: center, radius: round(radius-lineWidth/2), startAngle: CGFloat(segmentAngle * CGFloat(m)) + gapSize/2 - CGFloat(Double.pi/2), endAngle: CGFloat(segmentAngle * CGFloat(m+1) - gapSize/2) - CGFloat(Double.pi/2), clockwise: true).cgPath
        }
//        engine.mainMixerNode.volume = 0.0
//        tone.stop()
//        engine.reset()
        engineArray.last!.mainMixerNode.volume = 0.0
        print("end 1")
        toneArray.last!.stop()
        print("end 2")
        toneArray.removeLast()
        engineArray.last!.reset()
        print("end 3")
        engineArray.removeLast()

        setupToneAndEngine()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print("Touches began")
        let touch = touches.first!
        let location = touch.location(in: self.view)
        for i in 0...labelsArray.count - 1
        {
            if(labelsArray[i].frame.contains(location))
            {
                print("Location is contained at i: \(i)")

                circleLayerArray[i].lineWidth = lineWidth*2*1.3
                circleLayerArray[i].path = UIBezierPath(arcCenter: center, radius: round(radius-lineWidth/2), startAngle: CGFloat(segmentAngle * CGFloat(i)) + gapSize/2 - CGFloat(Double.pi/2), endAngle: CGFloat(segmentAngle * CGFloat(i+1) - gapSize/2) - CGFloat(Double.pi/2), clockwise: true).cgPath
                
                for k in 0...noteNameArray.count - 1
                {
                    if(labelsArray[i].text! == noteNameArray[k])
                    {
                        print("Found in array at k: \(k)")
                        // Switching tone, stop player and reset with new freq
//                        engine.mainMixerNode.volume = 0.0
//                        tone.stop()
//                        engine.reset()
                        engineArray.last!.mainMixerNode.volume = 0.0
                        toneArray.last!.stop()
                        toneArray.removeLast()
                        engineArray.last!.reset()
                        engineArray.removeLast()
                        
                        freq = 261.625565 * pow(2.0, Double(i)/Double(12) + Double(octave))
//                        tone.frequency = freq
//                        tone.preparePlaying()
//                        tone.play()
//                        engine.mainMixerNode.volume = 1.0
                        setupToneAndEngine()
                        toneArray.last?.frequency = freq
                        print("1")
                        toneArray.last?.preparePlaying()
                        print("2")
                        toneArray.last!.play()
                        print("3")
                        engineArray.last?.mainMixerNode.volume = 1.0
                        print("4")
                    }
                }
            }
        }
    }
}

