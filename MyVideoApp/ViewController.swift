//
//  ViewController.swift
//  MyVideoApp
//
//  Created by cis290 on 6/3/17.
//  Copyright © 2017 Rock Valley College. All rights reserved.
//

import UIKit
//1) Imports
import MobileCoreServices
import AVFoundation
import CoreData
import CoreMedia
import AVKit

//2 Add to ViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //2a Add variables
    var moviePlayer:AVPlayerViewController = AVPlayerViewController()
    
    var vidlink:String!
    
    //Add variable contactdb (used from UITableView
    var videodb:NSManagedObject!
    
    
    //Add ManagedObject Data Context
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //3 Create Outlets
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    @IBOutlet weak var txtDate: UITextField!
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var btnPlay: UIButton!
    
    @IBOutlet weak var btnRecord: UIButton!
    
    
    
    //4 Create Action for btnBack
    @IBAction func btnBack(_ sender: UIBarButtonItem) {
        //Code for func
        self.dismiss(animated: false, completion: nil)
    }
    
    //5 Create Action for btnBack
    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        //Code for func btnSave
        if (videodb != nil) {
            // Update existing device
            videodb.setValue(txtName.text, forKey: "name")
            
        } else {
            // Create a new device
            let entityDescription =
                NSEntityDescription.entity(forEntityName: "Video",
                                           in: managedObjectContext)
            
            let photod = Video(entity: entityDescription!,
                               insertInto: managedObjectContext)
            
            photod.name = txtName.text!
            photod.datestamp = txtDate.text!
            print("asdadadad: " + vidlink)
            photod.link = vidlink
        }
        //   var error: NSError?
        do {
            try managedObjectContext.save()
            self.dismiss(animated: false, completion: nil)
        } catch let error1 as NSError {
            print(error1)
        }
        
    }
    
    
    @IBAction func btnPlay(_ sender: UIButton) {
        //6  Code for func btnPlay
        let movieURL = NSURL.fileURL(withPath: vidlink!)
        
        let player = AVPlayer(url:movieURL as URL)
        
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame
        
        player.play()
    }
    
    // 7 Record Function
    func RecordVideo()
    {
        //Code for func
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            
            print("captureVideoPressed and camera available.")
            
            
            let imagePicker = UIImagePickerController()
            
            
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            
            imagePicker.allowsEditing = false
            
            imagePicker.showsCameraControls = true
            
            
            self.present(imagePicker, animated: true, completion: nil)
            
        }
            
        else {
            print("Camera not available.")
        }
        
    }
    
    @IBAction func btnRecord(_ sender: UIButton) {
        //8 Code ofr btnRecord Function
        if txtName.text == ""
        {
            let alert = UIAlertController(title: "Name Required", message: "Please add name for video", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            RecordVideo()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //9 Code to check if record selected
        if (videodb != nil) {
            //Code for func
            txtName.text = videodb.value(forKey: "name") as? String
            txtDate.text = videodb.value(forKey: "datestamp") as? String
            print(videodb.value(forKey: "datestamp") as! String)
            vidlink =  videodb.value(forKey: "link") as! String
            
            self.btnSave.title = "Update"
            btnSave.isEnabled = true
            
            btnRecord.isHidden=true
            
        } else {
            // Create a new device
            let date = NSDate()
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            formatter.string(from: date as Date)
            print(formatter.string(from: date as Date))
            txtDate.text = formatter.string(from: date as Date)
            txtName.becomeFirstResponder()
            btnPlay.isHidden=true
            btnSave.isEnabled = false
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //10 Prints when recording is finished playing
    func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
    }
    
    //11 ImagePicker finish recording
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])  {        //Code for func
        //Random #
        let myVar: Int = Int(arc4random())
        //        var strVar = String(myVar)
        
        let tempImage = info[UIImagePickerControllerMediaURL] as! NSURL!
        //        let fileManager = NSFileManager.defaultManager()
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        
        let name = txtName.text! + "\(myVar)" + ".MOV"
        
        let filePathToWrite = "\(paths)/\(name)"
        //  let MovieData:NSData = NSData(contentsOf: tempImage! as URL, options: .mappedIfSafe)
        do {
            let MovieData:NSData = try NSData(contentsOf: tempImage! as URL, options: .mappedIfSafe)
            MovieData.write(toFile: filePathToWrite, atomically: true)
            let pathString = tempImage?.relativePath
            vidlink = filePathToWrite
            print("Video Save Link: " + vidlink)
            
            UISaveVideoAtPathToSavedPhotosAlbum(pathString!, self, nil, nil)
            btnSave.isEnabled = true
            self.dismiss(animated: true, completion: {})
            
        } catch {
            print(error)
            return
        }
        
        
        
        
        
    }
    
    //12 Functions to complete recording
    func moviePlayerDidFinishPlaying(notification: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func videoEditorControllerDidCancel(editor: UIVideoEditorController) {
        print("User cancelled")
        self.dismiss(animated: true, completion: nil)
    }
    
    func videoEditorController(editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        print("editedVideoPath: " + editedVideoPath)
        self.dismiss(animated: true, completion: nil)
    }
    
    func videoEditorController(editor: UIVideoEditorController, didFailWithError error: NSError) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
