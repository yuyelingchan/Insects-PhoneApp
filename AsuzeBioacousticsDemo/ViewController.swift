//
//  ViewController.swift
//  AsuzeBioacousticsDemo
//
//  Created by acr on 21/07/2015.
//  Copyright (c) 2015 University of Southampton. All rights reserved.
//

import UIKit
import AVFoundation

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

class ViewController: UIViewController, AzureUploaderDelegate, AVAudioRecorderDelegate {
    
    var timer:NSTimer?
    
    var soundFileUrl:NSURL?

    var azureUploader:AzureUploader?
    
    var audioRecorder:AVAudioRecorder?
    
    let RECORDING_LENGTH = 10

    @IBOutlet var activityIndicator:UIActivityIndicatorView?
    
    @IBOutlet var circularProgressIndicator:CircularProgressIndicator?
    
    @IBOutlet var timerLabel:UILabel?
    @IBOutlet var statusLabel:UILabel?
    
    @IBOutlet var recordButton:UIButton?
    @IBOutlet var uploadButton:UIButton?
    
    override func viewDidLoad() {
    
        azureUploader = AzureUploader(delegate: self)
        
        setTimerLabelText(Double(RECORDING_LENGTH))
        
        var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioSession.setActive(true, error: nil)
        
        let documents: AnyObject = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true)[0]
        
        let str = documents.stringByAppendingPathComponent("recording.wav")
        
        soundFileUrl = NSURL.fileURLWithPath(str as String)

        var recordSettings = [
            AVFormatIDKey:kAudioFormatLinearPCM,
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:1,
            AVLinearPCMBitDepthKey:16
        ]
        
        var error: NSError?
        
        audioRecorder = AVAudioRecorder(URL:soundFileUrl, settings: recordSettings as [NSObject : AnyObject], error: &error)

        audioRecorder?.delegate = self

        if let e = error {
            
            println("Error initialising AVAudioRecorder")
            println(e.localizedDescription)
            
        }

    }
    
    func setTimerLabelText(value:Double) {
       
        timerLabel?.text = NSString(format: "%.1f", value) as String
        
        circularProgressIndicator?.setProgress(100.0 - 100.0 * value / Double(RECORDING_LENGTH))

    }
    
    @IBAction func uploadButtonPressed(sender: AnyObject?) {
  
        statusLabel?.text = "Converting"

        recordButton?.enabled = false
        
        uploadButton?.enabled = false
        
        activityIndicator?.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        
            // Read the file data
            
            var audioFile:AudioFileID = nil
            
            var status = AudioFileOpenURL(self.soundFileUrl, Int8(kAudioFileReadPermission), 0, &audioFile)
            
            if status == noErr {
                
                var size:UInt32 = 0
                
                var writable:UInt32 = 0
                
                status = AudioFileGetPropertyInfo(audioFile, AudioFilePropertyID(kAudioFilePropertyAudioDataByteCount), &size, &writable)
                
                if status == noErr {
                    
                    var numberOfBytes:UInt64 = 0
                    
                    status = AudioFileGetProperty(audioFile, AudioFilePropertyID(kAudioFilePropertyAudioDataByteCount), &size, &numberOfBytes)
                    
                    if status == noErr {
                
                        var startingByte:Int64 = 0
                    
                        var numberOfBytesToRead = UInt32(numberOfBytes)
                    
                        var buffer = Array<Int16>(count:Int(numberOfBytes / 2), repeatedValue: 0)
                    
                        status = AudioFileReadBytes(audioFile, Boolean(0), startingByte, &numberOfBytesToRead, &buffer)
                    
                        if status == noErr {
                    
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                                self.azureUploader?.upload(buffer)
                    
                                dispatch_async(dispatch_get_main_queue()) {
                    
                                    statusLabel?.text = "Uploading"
                    
                                }
                    
                            }
                    
                        } else {
                    
                            println("Error reading bytes")
                            println(status);
                    
                        }
                    
                    } else {
                    
                        println("Error reading file size")
                        println(status);
                    
                    }

                } else {
                    
                    println("Error reading property size")
                    println(status);
                    
                }
                
            } else {
                
                println("Error opening sound URL")
                println(status);
                
            }
            
            if status != noErr {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.statusLabel?.text = "Aborted"

                    self.activityIndicator?.stopAnimating()
                            
                    self.recordButton?.enabled = true
                            
                    self.setTimerLabelText(Double(self.RECORDING_LENGTH))
                    
                }
                
            }
                
        }
        
    }
    
    override func shouldAutorotate() -> Bool {
    
        return true
    
    }
    
    override func supportedInterfaceOrientations() -> Int {
        
        return Int((UIInterfaceOrientationMask.Portrait | UIInterfaceOrientationMask.PortraitUpsideDown).rawValue)
    
    }
    
    @IBAction func recordButtonPressed(sender: AnyObject?) {
        
        audioRecorder?.record()
        
        recordButton?.enabled = false
        
        uploadButton?.enabled = false
        
        statusLabel?.text = "Recording"
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
 
    }
    
    func update() {
        
        if let duration = audioRecorder?.currentTime {
            
            if duration > Double(RECORDING_LENGTH) {
 
                timer?.invalidate()
                
                audioRecorder?.stop()
                
            } else {
                
                setTimerLabelText(max(0.0, Double(RECORDING_LENGTH) - duration))
                
            }
            
        }

    }
    
    func audioRecorderDidFinishRecording(_recorder: AVAudioRecorder!, successfully flag: Bool) {
        
        if flag == false {
            println("Recording did not finish successfully")
        }
        
        setTimerLabelText(0.0)
        
        statusLabel?.text = "Complete"
        
        uploadButton?.enabled = true
        
        recordButton?.enabled = true
        
    }
    
    func finished(success: Bool) {
        
        if success {
            
            statusLabel?.text = "Ready"
            
        } else {
            
            statusLabel?.text = "Error"
            
        }
        
        activityIndicator?.stopAnimating()
        
        recordButton?.enabled = true
        
        setTimerLabelText(Double(self.RECORDING_LENGTH))
        
    }
    
    func uploadResponse(results: NSDictionary?) {
        
        var resultsValid = false
        println(results)
        
        let labels = (((results?["Results"] as? NSDictionary)?["Classification"] as? NSDictionary)?["value"] as? NSDictionary)?["ColumnNames"] as? [String]
        
        let values = (((results?["Results"] as? NSDictionary)?["Classification"] as? NSDictionary)?["value"] as? NSDictionary)?["Values"] as? [[AnyObject]]
        println(values)
        
        if let v = values?[0]{
            
            if let type = v[v.count - 1] as? String {

                var probabilities = [Double]()
                
                for var n=0; n<v.count-1; n++ {
                    if let probability = (v[n] as? String)?.toDouble() {
                        println("probability of \(labels?[n]) is \(probability)")
                    }
                }
                
                var storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    
                var analysisViewController = storyBoard.instantiateViewControllerWithIdentifier("analysisViewController") as! AnalysisViewController
                    
                if type == "Acrididae(grasshopper)" || type == "Cicadidae(cicada)" || type == "Gryllidae(cricket)" || type == "Tettigoniidae(bush cricket)" || type == "Gryllotalpidae(mole cricket)" {
                        
                    analysisViewController.message = type
                        
                    analysisViewController.image = UIImage(named: type)
                        
                } else if type == "No Insect" {
                        
                    analysisViewController.message = "It's just noise"
                        
                    analysisViewController.image = UIImage(named: "nobird")
                        
                } else if type == "noise" {
                    
                    analysisViewController.message = "It's just noise"
                    
                    analysisViewController.image = UIImage(named: "nobird")
                    
                } else {
                    
                    analysisViewController.message = type
                    
                    analysisViewController.image = UIImage(named: "bird")
                    
                }
                
                self.presentViewController(analysisViewController, animated: true, completion: { () -> Void in
                        
                    self.finished(true)
                        
                })
                    
            }
            
        }
        
        if !resultsValid {
            
            finished(false)
            
        }

    }

}

