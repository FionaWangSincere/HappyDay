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

class CollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var memories = [URL]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemories()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "add", style: .done, target: self, action:#selector(addTapped))
        
    }
    
    // open imagePickerController
    func addTapped(){
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.modalPresentationStyle = .formSheet
        navigationController?.present(vc, animated: true, completion: nil)
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
    
    //获得存储各种文件格式的地址
    func getDocumentDirection() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirection = paths[0]
        return documentDirection
    }
    
    func loadMemories(){
        memories.removeAll()
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentDirection(), includingPropertiesForKeys: nil, options: [])
        else {
            return
        }
        
        // loop over files founded
        for file in files {
            let fileName = file.lastPathComponent
            if fileName.hasSuffix(".thumb"){
                //get file root name without suffix
                let noExtensen = fileName.replacingOccurrences(of: ".thumb", with: "")
                // get file full path
                let memoryPath = getDocumentDirection().appendingPathComponent(noExtensen)
                memories.append(memoryPath)
            }
        }
        // reload list of memory
        collectionView?.reloadSections(IndexSet(integer:1))
    }
    
    // UIImagePickerViewDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            saveNewMemory(image: possibleImage)
            loadMemories()
        }
    }
    
    func saveNewMemory(image: UIImage){
        
        //creat union name for this memory
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        
        // Use union name to creat the new file name for the full-size image and the thumb
        let imageName = memoryName + ".jpg"
        let thumbnailName = memoryName + ".thumb"
        
        do {
            
            if let thumbnail = resize(image: image, to: 200){
            //creat URL you can make JEPG image to ...
            let imagePath = getDocumentDirection().appendingPathComponent(thumbnailName)
            //conver image to the JEPG data object
            if let jepgData = UIImageJPEGRepresentation(thumbnail, 80){
                
                //write that data to URL we creat
                try jepgData.write(to: imagePath, options: [.atomicWrite])
            }
        } // creat thumbnail here
        }catch{
            print("Flaid to write to disk")
        }
    }
    
    // creat thumbnails
    
    func resize(image: UIImage, to width: CGFloat) -> UIImage?{
        
        // calculate how much we need to bring the width down to match our target size”
        let scale = width / image.size.width
        
        // bring the height down by the same amount so that the aspect ratio is preserved”
        let height = image.size.height * scale
        
        // creat a new content we can draw to
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width, height:height), false, 0)
        
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        //put out the resized version
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        // end the context so that the UIKit can clean up
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    //depaly memories
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return 0
        }else{
            return memories.count
        }
    }
    
    func imageURL(for memory:URL)-> URL{
        return memory.appendingPathExtension("jpg")
    }
    
    func thumbURL(for memory: URL)-> URL{
        return memory.appendingPathExtension("thumb")
    }
    
    func audioURL(for memory: URL)-> URL{
        return memory.appendingPathExtension("m4a")
    }
    
    func transcribtionURL(for memory: URL) -> URL{
        return memory.appendingPathExtension("txt")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Memory", for: indexPath) as! MemoryCell
        
        let memory = memories[indexPath.row]
        let imageName = thumbURL(for: memory).path
        let image = UIImage(contentsOfFile: imageName)
        cell.imageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    }
    
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1{
            return CGSize.zero
        }else{
            return CGSize(width: 0, height: 50)
        }
    }
    
}















