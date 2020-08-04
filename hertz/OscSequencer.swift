//
//  OscSequencer.swift
//  hertz
//
//  Created by Cameron Krischel on 4/4/19.
//  Copyright © 2019 Cameron Krischel. All rights reserved.
//

import Foundation
import AudioKit

class OscSequencer
{
    let oscBank = AKOscillatorBank()//1
    let sequencer = AKSequencer()//2
    let midi = AKMIDI()//3
    let sequenceLength = AKDuration(beats: 8.0)
}

func setupSynth() {
    oscBank.attackDuration = 0.1
    oscBank.decayDuration = 0.1
    oscBank.sustainLevel = 0.1
    oscBank.releaseDuration = 0.3
}
func doSomeStuff {
    let midiNode = AKMIDINode(node: oscBank)//1
    _ = sequencer.newTrack()//2
    sequencer.setLength(sequenceLength)//3
    generateSequence() //4
    AudioKit.output = midiNode//5
    AudioKit.start()//6
    midiNode.enableMIDI(midi.client, name: "midiNode midi in")//7
    sequencer.setTempo(120.0)//8
    sequencer.enableLooping()//9
    sequencer.play()//10
}

func generateSequence() {
    let stepSize: Float = 1/8 //1
    sequencer.tracks[0].clear() //2
    let numberOfSteps = Int(Float(sequenceLength.beats)/stepSize)//3
    print("NUMBER OF STEPS********** \(numberOfSteps)")
    for i in 0 ..< numberOfSteps { //4
        if i%4 == 0 {
            sequencer.tracks[0].add(noteNumber: 69, velocity: 127, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.5))
        } else {
            sequencer.tracks[0].add(noteNumber: 57, velocity: 127, position: AKDuration(beats: Double(i)), duration: AKDuration(beats: 0.5))
        }
    }
}
