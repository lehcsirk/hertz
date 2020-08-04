//simple main.swift that plays a square wave; shown by Doug Wyatt at WWDC 2016
//(likely) requires swift3
//circa Aug 1, 2016 --> will likely not work in a few months as swift 3 changes things related to Unsafe pointers

import Foundation
import AudioToolbox
import AVFoundation

class SquareWaveGenerator {
    let sampleRate: Double
    let frequency : Double
    let amplitude : Float
    var counter   : Double  = 0.0
    
    init(sampleRate: Double, frequency: Double, amplitude: Float){
        self.amplitude = amplitude
        self.frequency = frequency
        self.sampleRate = sampleRate
    }
    
    func render(buffer: AudioBuffer) {
        let nframes = Int(buffer.mDataByteSize) / sizeof(Float.self)
        var ptr = UnsafeMutablePointer<Float>(buffer.mData)!
        var j = self.counter
        let cycleLength = self.sampleRate / self.frequency
        
        let halfCycleLength = cycleLength / 2
        let amp = self.amplitude, minusAmp = -amplitude
        for _ in 0 ..< nframes {
            if j < halfCycleLength {
                ptr.pointee = amp
            }
            else {
                ptr.pointee = minusAmp
            }
            ptr = ptr.successor()
            j += 1.0
            if ( j > cycleLength) {
                j -= cycleLength
            }
        }
        self.counter = j
    }
}
print("Hello, World!")
let subType = kAudioUnitSubType_HALOutput
let ioUnitDesc = AudioComponentDescription(componentType: kAudioUnitType_Output, componentSubType: subType, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)

let ioUnit = try! AUAudioUnit(componentDescription: ioUnitDesc)
let hardwareFormat = ioUnit.outputBusses[0].format
let renderFormat = AVAudioFormat(standardFormatWithSampleRate: hardwareFormat.sampleRate, channels: hardwareFormat.channelCount)

try! ioUnit.inputBusses[0].setFormat(renderFormat)

let generatorLeft = SquareWaveGenerator(sampleRate: renderFormat.sampleRate, frequency: 440.0, amplitude: 0.1)
let generatorRight = SquareWaveGenerator(sampleRate: renderFormat.sampleRate, frequency: 660.0, amplitude: 0.1)



let callback : AURenderPullInputBlock = {
    ( flags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    ts: UnsafePointer<AudioTimeStamp>,
    fc: AUAudioFrameCount,
    bus: Int,
    rawBuff: UnsafeMutablePointer<AudioBufferList>) -> AUAudioUnitStatus
    in
    let bufferList = UnsafeMutableAudioBufferListPointer(rawBuff)
    if bufferList.count > 0 {
        generatorLeft.render(buffer: bufferList[0])
        if bufferList.count > 1 {
            generatorRight.render(buffer: bufferList[1])
            
        }
    }
    return noErr
}


ioUnit.outputProvider = callback

try! ioUnit.allocateRenderResources()
try! ioUnit.startHardware()

sleep(3)
ioUnit.stopHardware()


