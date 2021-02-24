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
        
        view.backgroundColor = .cyan
        
        statusBarStyle = .default
        navBackgroundColor = .yellow
        navShadowColor = .blue
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if statusBarStyle == .lightContent {
            statusBarStyle = .default
        } else {
            statusBarStyle = .lightContent
        }
    }
    
    @IBAction func photoButtonEvent(_ sender: Any) {
        showImagePickerController()
//        pushTest()
    }
    
    func pushTest() {
        
        
        let vc = UIViewController()
        
        vc.view.backgroundColor = .blue
        vc.navigationItem.leftItemsSupplementBackButton = true // 设置 leftBarButtonItem 不会占用掉返回按钮
        
        if #available(iOS 14.0, *) {
            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .bookmarks)
        } else {
            // Fallback on earlier versions
        }
        navigationController?.pushViewController(vc, animated: true)
        
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
            maxImagesCount: 9,
            columnNumber: 3,
            delegate: self,
            pushPhotoPickerVc: true)!
        
//        imagePicker.barItemTextColor = navTintColor
//        imagePicker.navBackgroundColor = .orange
        
        imagePicker.allowPickingOriginalPhoto = false
        imagePicker.allowPickingVideo = false
        imagePicker.alwaysEnableDoneBtn = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        print("我")
    }
}
