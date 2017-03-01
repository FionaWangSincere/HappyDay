//
//  CollectionViewController.swift
//  HappyDay
//
//  Created by kangkang on 2017/2/27.
//  Copyright © 2017年 kangkang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Speech
import CoreSpotlight
import MobileCoreServices

class CollectionViewController: UICollectionViewController, AVAudioRecorderDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       checkPermission()
    }
    
    func checkPermission(){
        let photoPermission = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordPermission = AVAudioSession.sharedInstance().recordPermission() == .granted
        let triscriptionPermission = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        let authorized = photoPermission && recordPermission && triscriptionPermission
        
        if authorized == false{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FirstView"){
                navigationController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
}
    
