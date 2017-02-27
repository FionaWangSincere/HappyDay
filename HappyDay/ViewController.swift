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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadNavigation()
        labelText.text = "In order to work fully, Happy Days needs to read your photo library, record your voice, and transcribe what you said. When you click the button below you will be asked to grant those permissions, but you can change your mind later in Settings."
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadNavigation(){
        self.navigationItem.rightBarButtonItem?.title = "Welcome"
        self.navigationController?.navigationBar.backgroundColor = UIColor.purple
        let rightBar = UIBarButtonItem.init(title: "ADD", style: .done, target: self, action: #selector(changeColor))
        self.navigationItem.rightBarButtonItem = rightBar
        
    }
    @IBOutlet weak var labelText: UILabel!
    
    func changeColor() -> UIView{
        self.view.backgroundColor = UIColor.yellow
        return self.view
        
    }
    
    func requestPhotosPermissions(){
        PHPhotoLibrary.requestAuthorization{[unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized{
                    self.requestPhotosPermissions()
                }else{
                    self.labelText.text = "Photos permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func requestRecordPermissions(){
        AVAudioSession.sharedInstance().requestRecordPermission(){
            [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.requestTranscribePermissions()
                }else{
                    self.labelText.text = "Recording permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func requestTranscribePermissions(){
        SFSpeechRecognizer.requestAuthorization{[unowned self] authStatus in
            
            DispatchQueue.main.async {
                if authStatus == .authorized{
                    self.anthorizationComplete()
                }else{
                    self.labelText.text = "Transcription permission was declined; please enable it in settings then tap Continue again."
                }
            }
        }
    }
    
    func anthorizationComplete(){
        dismiss(animated: true)
    }
}





















