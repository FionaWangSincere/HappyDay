//
//  ViewController.swift
//  HappyDay
//
//  Created by kangkang on 2017/2/27.
//  Copyright © 2017年 kangkang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech


class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       self.navigationItem.title = "Welcome"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        requestPhotoPremession()
    }
    
    func requestPhotoPremession(){
        PHPhotoLibrary.requestAuthorization{
            [unowned self] authStatue in
                DispatchQueue.main.sync {
                    if authStatue == .authorized{
                        self.requestRecordPermession()
                    }else{
                        self.textLabel.text = "Transcription permission was declined; please enable it in settings then tap Continue again."
                    }
            }
        }
    
    }
    
    func requestRecordPermession(){
        AVAudioSession.sharedInstance().requestRecordPermission(){
            [unowned self] allow in
            DispatchQueue.main.sync {
                if allow {
                    self.requestTranscribtionPermession()
                }else{
                    self.textLabel.text = "Recording permission was declined; please enable it in settings then tap Continue again"
                }
            }
        }
    }
    
    func requestTranscribtionPermession(){
        SFSpeechRecognizer.requestAuthorization{
            [unowned self] authStatue in
            DispatchQueue.main.sync {
                if authStatue == .authorized{
                    self.permissionComplate()
                }else{
                    self.textLabel.text = "Transcription permission was declined,please enable it in settings then tap Continue again"
                }
            }
        }
    }
    
    func permissionComplate(){
        dismiss(animated: true, completion: nil)
    }
}





















