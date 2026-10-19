import Foundation
import AVFoundation

public class SoundEngine {
    public static let shared = SoundEngine()
    
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let bgmNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100.0
    private var isEngineRunning = false
    
    // Scale for bit collection
    private let pentatonicFrequencies: [Double] = [
        523.25, // C5
        587.33, // D5
        659.25, // E5
        783.99, // G5
        880.00, // A5
        1046.50 // C6
    ]
    private var noteIndex: Int = 0
    
    private init() {
        setupEngine()
    }
    
    private func setupEngine() {
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            
            audioEngine.attach(playerNode)
            audioEngine.attach(bgmNode)
            
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
            audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
            audioEngine.connect(bgmNode, to: audioEngine.mainMixerNode, format: format)
            
            audioEngine.mainMixerNode.outputVolume = 0.8
            
            try audioEngine.start()
            isEngineRunning = true
            startAmbientPulse()
        } catch {
            print("SoundEngine failed to initialize: \(error.localizedDescription)")
            isEngineRunning = false
        }
    }
    
    // Helper to generate PCM Buffer
    private func generateBuffer(duration: Double, wave: (Double) -> Float) -> AVAudioPCMBuffer? {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return nil }
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        let channelData = buffer.floatChannelData![0]
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            channelData[frame] = wave(t)
        }
        return buffer
    }
    
    public func playDash() {
        guard GameState.shared.soundEnabled, isEngineRunning else { return }
        let duration = 0.12
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let progress = t / duration
            let freq = 400.0 + progress * 800.0
            let env = Float(1.0 - progress)
            return sin(Float(2.0 * .pi * freq * t)) * env * 0.25
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playCollectBit(combo: Int) {
        guard GameState.shared.soundEnabled, isEngineRunning else { return }
        let baseFreq = pentatonicFrequencies[noteIndex % pentatonicFrequencies.count]
        noteIndex += 1
        let duration = 0.15
        
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(max(0.0, 1.0 - (t / duration) * 1.5))
            // Bell-like harmonic
            let wave1 = sin(Float(2.0 * .pi * baseFreq * t))
            let wave2 = sin(Float(2.0 * .pi * (baseFreq * 2.0) * t)) * 0.4
            return (wave1 + wave2) * env * 0.3
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playGraze() {
        guard GameState.shared.soundEnabled, isEngineRunning else { return }
        let duration = 0.2
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(1.0 - t / duration)
            let freq = 1200.0 + sin(t * 80.0) * 300.0
            return sin(Float(2.0 * .pi * freq * t)) * env * 0.35
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playHyperdrive() {
        guard GameState.shared.soundEnabled, isEngineRunning else { return }
        let duration = 0.5
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let progress = t / duration
            let freq = 200.0 + progress * progress * 1600.0
            let env = Float(min(1.0, progress * 4.0) * (1.0 - progress * 0.5))
            // Sawtooth wave approximation
            let phase = Float((freq * t).truncatingRemainder(dividingBy: 1.0))
            let saw = 2.0 * phase - 1.0
            return saw * env * 0.35
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    public func playCrash() {
        guard GameState.shared.soundEnabled, isEngineRunning else { return }
        let duration = 0.45
        if let buffer = generateBuffer(duration: duration, wave: { t in
            let env = Float(pow(1.0 - t / duration, 2.0))
            let subFreq = max(30.0, 150.0 - (t / duration) * 110.0)
            let sine = sin(Float(2.0 * .pi * subFreq * t))
            let noise = Float.random(in: -0.3...0.3) * Float(1.0 - t / duration)
            return (sine * 0.7 + noise * 0.3) * env * 0.5
        }) {
            playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !playerNode.isPlaying { playerNode.play() }
        }
    }
    
    private func startAmbientPulse() {
        guard isEngineRunning else { return }
        let beatDuration = 0.25
        let totalLoopDuration = 1.0 // 4 beats loop at 120 BPM
        
        if let loopBuffer = generateBuffer(duration: totalLoopDuration, wave: { t in
            guard GameState.shared.soundEnabled else { return 0.0 }
            let beatTime = t.truncatingRemainder(dividingBy: beatDuration)
            let env = Float(max(0.0, 1.0 - beatTime / 0.12))
            let sub = sin(Float(2.0 * .pi * 65.41 * beatTime)) // C2 bass pulse
            return sub * env * 0.08
        }) {
            bgmNode.scheduleBuffer(loopBuffer, at: nil, options: .loops, completionHandler: nil)
            bgmNode.play()
        }
    }
}
