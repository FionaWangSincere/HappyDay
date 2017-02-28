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

@available(iOS 10.0, *)

class CollectionViewController: UICollectionViewController, UISearchBarDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout,AVAudioRecorderDelegate {
    
    var memories = [URL]()
    var filteredMemories = [URL]()
    var activeMemory : URL!
    
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var recordingURL: URL!
    
    var searchQuery: CSSearchQuery?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        recordingURL = getDocumentsDirectory().appendingPathComponent("recording.mp4")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      checkPermissions()
    }
    
    func checkPermissions(){
        let photosAuthorized = PHPhotoLibrary.authorizationStatus() == .authorized
        let recordingAuthorized = AVAudioSession.sharedInstance().recordPermission() == .granted
        let transcibeAuthorized = SFSpeechRecognizer.authorizationStatus() == .authorized
        
        let authorized = photosAuthorized && recordingAuthorized && transcibeAuthorized
        
        if authorized == false{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "FirstRun"){
                navigationController?.present(vc, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapped (){
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        navigationController?.present(vc, animated: true)
    }
    
    func getDocumentsDirectory()->URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func loadMemory(){
        memories.removeAll()
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: [])
        else {
            return
        }
        
        for file in files {
            let filename = file.lastPathComponent
            
            if filename.hasSuffix(".thumb"){
                let noExtension = filename.replacingOccurrences(of: ".thumb", with: "")
                let memoryPath = getDocumentsDirectory().appendingPathComponent(noExtension)
                memories.append(memoryPath)
            }
        }
        
        filteredMemories = memories
        collectionView?.reloadSections(IndexSet(integer: 1))
    }


    func loadNavigationItem(){
        let rightBar = UIBarButtonItem.init(title: "ADD", style: .done, target: self, action: #selector(changeColor))
        self.navigationItem.rightBarButtonItem = rightBar
    }
    
    func changeColor() -> UIView{
        self.view.backgroundColor = UIColor.yellow
        return self.view
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
        
        if let possibleImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage{
            saveNewMemory(image: possibleImage)
            loadMemory()
        }
    }
    
    func saveNewMemory(image: UIImage){
        let memoryName = "memory-\(Date().timeIntervalSince1970)"
        let imageName = memoryName + ".jpg"
        let thumbnailName = memoryName + ".thumb"
        
        do {
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            if let jpegData = UIImageJPEGRepresentation(image, 80){
                try jpegData.write(to: imagePath, options: [.atomicWrite])
            }
            
            if let thumbnail = resize(image:image, to:200){
                let imagePath = getDocumentsDirectory().appendingPathComponent(thumbnailName)
                if let jpegData = UIImageJPEGRepresentation(thumbnail, 80){
                    try jpegData.write(to:imagePath, options:[.atomicWrite])
                }
            }
        }catch{
            print("Fiald to save to disk.")
        }
    }
    
    func resize(image: UIImage , to width : CGFloat)->UIImage?{
        let scale = width / image.size.width
        let height = image.size.height * scale

    UIGraphicsBeginImageContextWithOptions(CGSize(width:width, heigth:height), false, 0)
    image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
      
        return 2
    }

    func imageURL(for memory:URL)->URL{
        return memory.appendingPathExtension("jpg")
    }
    
    func thumbnailURL(for memory: URL)-> URL{
        return memory.appendingPathExtension("thumb")
    }
    
    func audioURL (for memory :URL)-> URL{
        return memory.appendingPathExtension("m4a")
    }
    
    func transcriptionURL(for memory: URL)->URL{
        return memory.appendingPathExtension("txt")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 0
        }else{
            return filteredMemories.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Memory", for: indexPath)
        
        let memory = filteredMemories[indexPath.row]
        let imageName = thumbnailURL(for: memory).path
        let image = UIImage(contentsOfFile: imageName)
        cell.imageView.image = image
        
        if cell.gestureRecognizers == nil{
            let recognizer = UILongPressGestureRecognizer(target: self, action: <#T##Selector?#>)
            recognizer.minimumPressDuration = 0.25
            cell.addGestureRecognizer(recognizer)
            
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 3
            cell.layer.cornerRadius = 10
        }
    
        // Configure the cell
    
        return cell
    }

    func memoryLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .begin{
            let cell = sender.view
            if let index = collectionView?.indexPath(for: cell){
                activeMemory = filteredMemories[index.row]
            
            }
        }
    }
    
    func recordMemory(){
        
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
