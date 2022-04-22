//
//  ViewController.swift
//  Video-Exam
//
//  Created by Coffee Bean on 22.04.2022.
//

import UIKit
import AVFoundation
import CoreMotion

class ViewController: UIViewController {
    
    private var videoURL = Bundle.main.url(forResource: "WeAreGoingOnBullrun", withExtension: "mp4")!
    
    private var playerLooper: AVPlayerLooper!
    private var queuePlayer: AVQueuePlayer!
    private var playerLayer: AVPlayerLayer?
    
    private var motionManager: CMMotionManager!
    
    private let rollThreshhold: Double = 3.0
    
    @IBOutlet weak var playerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: Notification.Name(rawValue:"didUpdateLocation"), object: nil)

        initializeAVPlayer()
        initializeMotionManager()
    }

    // MARK: Initializers
    
    private func initializeAVPlayer() {
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: queuePlayer)
        
        playerLayer?.frame = playerView.bounds
        
        if let playerLayer = playerLayer {
            playerView.layer.addSublayer(playerLayer)
        }
        
        queuePlayer.play()
    }
    
    private func initializeMotionManager() {
        motionManager = CMMotionManager()

        motionManager.gyroUpdateInterval = 0.1

        motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
            if let data = data { self.handleRotation(for: data) }
        }
    }
    
    // MARK: Data handlers
    
    private func handleRotation(for data: CMDeviceMotion) {
        queuePlayer.volume = Float(data.attitude.pitch)
        
        let zRate = data.rotationRate.z
        if zRate.magnitude >= rollThreshhold {
            seek(by: -zRate)
        }
        
    }
    
    @objc private func locationUpdated() {
        queuePlayer.seek(to: .zero)
    }
    
    // MARK: AVPlayer controls
    
    private func seek(by seconds: Double) {
        guard let duration  = queuePlayer?.currentItem?.duration else {
            return
        }
        
        let playerCurrentTime = CMTimeGetSeconds(queuePlayer!.currentTime())
        let newTime = playerCurrentTime + seconds

        if newTime < (CMTimeGetSeconds(duration) - seconds) {
            let seekTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            queuePlayer!.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
    
    // MARK: Overrides
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            switch queuePlayer.timeControlStatus {
            case .playing: queuePlayer.pause()
            case .paused: queuePlayer.play()
            default: break
            }
        }
    }
    
    // MARK: State changes
    
    @objc private func orientationChanged() {
        // Update playerLayer size on screen orientation change
        playerLayer?.frame = playerView.bounds
    }
    
    @objc func didEnterBackground() {
        if let currentItem = queuePlayer.currentItem {
            let itemTrack = currentItem.tracks.first
            
            if let assetTrack = itemTrack?.assetTrack, assetTrack.hasMediaCharacteristic(AVMediaCharacteristic.visual) {
                itemTrack?.isEnabled = false
            }
        }
        
        playerLayer?.player = nil
    }

    @objc func willEnterForeground() {
        if let currentItem = queuePlayer.currentItem {
            let itemTrack = currentItem.tracks.first
            
            if let assetTrack = itemTrack?.assetTrack, assetTrack.hasMediaCharacteristic(AVMediaCharacteristic.visual) {
                itemTrack?.isEnabled = true
            }
        }
        
        playerLayer?.player = queuePlayer
    }
}

