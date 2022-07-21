//
//  XQuickPreviewController.swift
//  TankerPallet
//
//  Created by Xwg on 2021/1/14.
//  Copyright © 2021 Yelopack. All rights reserved.
//

import Foundation
import QuickLook


class XQuickPreviewController: QLPreviewController {

    var items: [URL] = []
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        currentPreviewItemIndex = currentIndex
    }
}

extension XQuickPreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return items[index] as QLPreviewItem
    }
}

