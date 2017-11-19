//
//  ViewController.swift
//  Heart Rate
//
//  Created by Ege on 15.11.17.
//  Copyright © 2017 Ege. All rights reserved.
//

import UIKit

import CoreImage
import AVKit
class ViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate{
    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var startTime:Double?
    var elapsedTime:Double?
    var Brightness = [0]
    var beated = 0
    
    @IBOutlet weak var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.black
        captureDevice = AVCaptureDevice.default(for: .video)
        captureSession.sessionPreset = .cif352x288
        guard let input = try? AVCaptureDeviceInput(device: captureDevice!) else {return}
        captureSession.addInput(input)
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        captureSession.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        try? captureDevice?.lockForConfiguration()
        captureDevice?.torchMode = .on
        captureDevice?.unlockForConfiguration()
    }
    
    //find local minimums, ignoring very small changes
    func findBigDips() -> [Int]{
        let localBrightness:[Int] = Array( Brightness.suffix(500))
        var dips = [Int]()
        var index  = 1
        var localmin = 255
        let searchRange = 7
        while index < localBrightness.count - 1 {
            var localMinFound = false
            
            if localBrightness[index] == localmin || localBrightness[index] == localmin+1{
                localMinFound = false
                index += 1
                continue
            }
            else {
                localmin = 255
            }
            
            for j in 1..<searchRange{
                if (index-j) < 0 {
                    if localBrightness[index] <= localBrightness[0] && localBrightness[index] <= localBrightness[index+j]{
                        
                        localMinFound = true
                    }
                    else{
                        localMinFound = false
                        break
                    }
                }
                else if (index+j >= localBrightness.count){
                    if localBrightness[index] <= localBrightness[index - j] && localBrightness[index] <= localBrightness[localBrightness.count - 1]{
                        localMinFound = true
                    }
                    else{
                        localMinFound = false
                        break
                    }
                }
                else {
                    if localBrightness[index] <= localBrightness[index - j] && localBrightness[index] <= localBrightness[index+j]{
                        localMinFound = true
                    }
                    else{
                        localMinFound = false
                        break
                    }
                }
            }
            if localMinFound {
                localmin = localBrightness[index]
                dips.append(index)
            }
            index += 1
        }
        return dips
    }
    
    func averageBeats(){
        //        every 250th time the dips will be calculated
        if Brightness.count % 250 == 0{
            let dipIndexes = findBigDips()
            let dips = Double(dipIndexes.count)
            elapsedTime = Date.timeIntervalSinceReferenceDate - startTime!
            if Brightness.count > 300 {
                //                doubled because after 250 photos, findBigDips uses 500 photos instead of 250
                elapsedTime! *= 2.0
            }
            let perSecondDips:Double = dips / (elapsedTime!)
            DispatchQueue.main.async {
                let dipAsInt:Int = Int(perSecondDips * 60)
                self.heartRateLabel.text = "BPM: \(dipAsInt)"
            }
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    //    gets all the images as outputs
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if startTime == nil {
            startTime = Date.timeIntervalSinceReferenceDate
        }
        guard let pixelBuffer:CVPixelBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer) else { return}
        //        create ciimage
        let ciimage = CIImage(cvPixelBuffer: pixelBuffer)
        //        create cgimage
        let context = CIContext()
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        //        create UIImage
        let ui = UIImage(cgImage: cgImage)
        //        use rgbaImage and brigthness extension to get the brigtness of the red channel
        let redBright = ui.brigthness(red: true, green: false, blue: false)
        //        at the very start there are some null values, they should not be added to the data
        if redBright != 0{
            Brightness.append(redBright)
        }
        averageBeats()
    }
}
