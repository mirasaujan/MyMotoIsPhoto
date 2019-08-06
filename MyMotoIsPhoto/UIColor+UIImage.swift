//
//  UIColor+UIImage.swift
//  MyMotoIsPhoto
//
//  Created by Miras Karazhigitov on 8/6/19.
//  Copyright © 2019 Miras Karazhigitov. All rights reserved.
//

import UIKit

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
