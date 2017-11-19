//
//  brigthnessExtension.swift
//  Heart Rate
//
//  Created by Ege on 16.11.17.
//  Copyright © 2017 Ege. All rights reserved.
//

import UIKit

extension UIImage {
    
    //    brigthness from 0 to 255
    //    all true for overall brightness
    func brigthness(red r:Bool , green g:Bool , blue b:Bool) -> Int{
        
        guard let asRgbaImage = RGBAImage(image: self) else {return 0}
        
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        
        for y in 0..<asRgbaImage.height {
            for x in 0..<asRgbaImage.width {
                let index = y * asRgbaImage.width + x
                let pixel = asRgbaImage.pixels[index]
                totalRed += Int(pixel.R)
                totalGreen += Int(pixel.G)
                totalBlue += Int(pixel.B)
            }
        }
        
        let pixelCount = asRgbaImage.width * asRgbaImage.height
        let avgRed = totalRed / pixelCount
        let avgGreen = totalGreen / pixelCount
        let avgBlue = totalBlue / pixelCount
        
        if r && g && b {
            return (avgRed + avgGreen + avgBlue) / 3
        }
        else if r {
            return avgRed
        }
        else if g{
            return avgGreen}
        else if b{
            return avgBlue}
            
        else{
            return 0}
    }
    
    
}
