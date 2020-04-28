//
//  TestImagePickerController.swift
//  XNavigationBar_Example
//
//  Created by Xwg on 2020/2/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class TestImagePickerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navBackgroundColor = .yellow
    }

    @IBAction func photoButtonEvent(_ sender: Any) {
        showImagePickerController()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: 选择图片处理
extension TestImagePickerController: TZImagePickerControllerDelegate {
    
    /// 显示选择相册
    func showImagePickerController() {
      
        let imagePicker = TZImagePickerController(
            maxImagesCount: 1,
            columnNumber: 3,
            delegate: self,
            pushPhotoPickerVc: true)!
        
        imagePicker.modalPresentationStyle = .overFullScreen
        imagePicker.navTitleColor = .blue
        imagePicker.barItemTextColor = navTintColor
        imagePicker.naviBgColor = navBackgroundColor
        
        imagePicker.allowPickingOriginalPhoto = false
        imagePicker.allowPickingVideo = false
        imagePicker.alwaysEnableDoneBtn = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        print("我")
    }
}
