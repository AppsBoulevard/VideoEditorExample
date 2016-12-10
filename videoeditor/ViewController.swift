//
//  ViewController.swift
//  videoeditor
//
//  Created by Oscar J. Irun on 10/12/16.
//  Copyright © 2016 appsboulevard. All rights reserved.
//

import UIKit
import AVFoundation
import ABVideoRangeSlider


class ViewController: UIViewController, ABVideoRangeSliderDelegate {

    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPause: UIButton!
    @IBOutlet var videoContainer: UIView!
    @IBOutlet var rangeSlider: ABVideoRangeSlider!
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var timeObserver: AnyObject!
    var startTime = 0.0;
    var endTime = 0.0;
    var progressTime = 0.0;
    var shouldUpdateProgressIndicator = true
    var isSeeking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.path(forResource: "test", ofType:"mp4")!
        
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        
        videoContainer.layer.insertSublayer(avPlayerLayer, at: 0)
        videoContainer.layer.masksToBounds = true
        
        rangeSlider.setVideoURL(videoURL: URL(fileURLWithPath: path))
        rangeSlider.delegate = self
        
        self.endTime = CMTimeGetSeconds((avPlayer.currentItem?.duration)!)
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.01, 100)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,
                                                        queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                            self.observeTime(elapsedTime: elapsedTime) } as AnyObject!
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avPlayerLayer.frame = videoContainer.bounds
    }
    
    @IBAction func playTapped(_ sender: Any) {
        avPlayer.play()
        shouldUpdateProgressIndicator = true
        btnPlay.isEnabled = false
        btnPause.isEnabled = true
    }

    @IBAction func pauseTapped(_ sender: Any) {
        avPlayer.pause()
        btnPlay.isEnabled = true
        btnPause.isEnabled = false
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let elapsedTime = CMTimeGetSeconds(elapsedTime)
 
        if (avPlayer.currentTime().seconds > self.endTime){
            avPlayer.pause()
            btnPlay.isEnabled = true
            btnPause.isEnabled = false
        }
        
        if self.shouldUpdateProgressIndicator{
            rangeSlider.updateProgressIndicator(seconds: elapsedTime)
        }
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        self.shouldUpdateProgressIndicator = false
        
        // Pause the player
        avPlayer.pause()
        btnPlay.isEnabled = true
        btnPause.isEnabled = false
        
        if self.progressTime != position {
            self.progressTime = position
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.progressTime, timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                    self.isSeeking = false
                }
            }
        }
        
    }

    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        
        self.endTime = endTime
        
        if startTime != self.startTime{
            self.startTime = startTime
            
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.startTime, timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                    self.isSeeking = false
                }
            }
        }
    }
}

