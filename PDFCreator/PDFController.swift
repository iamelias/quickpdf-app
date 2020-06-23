//
//  ViewController.swift
//  PDFCreator
//
//  Created by Elias Hall on 6/9/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
// App Name:  QuickPDF

import Foundation
import UIKit
import VisionKit
import PDFKit

class PDFController: UIViewController {
    
    //Below is U.S. Letter dimensions, A4 would be: pageWidth = 612, pageHeight = 842
    public var documentData: Data?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    static let documentIdentifier = "documentIdentifier"
    var capturedImage = UIImage()
    var urlDocumentsDirectory: URL?
    var pdfName: String = ""
    let pdfExt = ".pdf"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editDefaultView()
    }
    
    @IBAction func previewButtonTapped(_ sender: Any) { //unecessary
        callPreview()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        pdfName = "" //clear pdfName for new PDF
        pdfNameAlert()
    }
    
    func editDefaultView() {
        activityIndicator.isHidden = true
        imageView.isHidden = true
    }
    
    func savePdf(pdfDocument: PDFDocument) {
        let data = pdfDocument.dataRepresentation()
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = documentDirectory.appendingPathComponent("\(pdfName)\(pdfExt)")
        urlDocumentsDirectory = path
        
        do {
            try data?.write(to: path)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func callPreview() {
        print("callPreview called at completion")
        performSegue(withIdentifier: "previewSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewSegue" {
            guard let vc = segue.destination as? PdfPreviewController else { return }
            vc.passedURL = urlDocumentsDirectory
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if
            let _ = imageView.image {
            return true
        }
        return false
    }
    
    func showDisplayImage(image: UIImage) { //shows image in PDFController uiview
        let originalImage = image
        let newImage = compressedImage(originalImage)
        capturedImage = originalImage
        processImage(newImage)
    }
    
    func processImage(_ image: UIImage) { //unhiding uiimageview after image is saved to display
        imageView.isHidden = false
        imageView.image = image
    }
    
    func compressedImage(_ originalImage: UIImage) -> UIImage {
        guard let imageData = originalImage.jpegData(compressionQuality: 1),
            let reloadedImage = UIImage(data: imageData) else {
                return originalImage
        }
        return reloadedImage
    }
    
    func checkFormat() -> Bool { //checking if string is in acceptable format
        
        let filteredName = pdfName.replacingOccurrences(of: " ", with: "") //removing all spaces in title, can't have of a title consisting of only spaces
        
        guard filteredName.count != 0 else { //checking if Name is 0, meaning no title was entered
            return false
        }
        return true
    }
    
    //MARK: ALERTS
    
    func pdfNameAlert() {
        let alert = UIAlertController(title: "PDF's Title", message: "Please enter title below", preferredStyle: .alert)
        alert.addTextField {textField in
            textField.placeholder = "Resume01"
            textField.textAlignment = .center
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("cancelled")
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) {[unowned alert] _ in
            print("Ok tapped")
            self.pdfName = alert.textFields?[0].text ?? ""
            guard self.checkFormat() else {return} //check if title is in reasonable format
            
            self.useVNScanner()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert,animated: true)
    }
    
    func useVNScanner() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true) //presents scanner on screen
    }
}

//MARK: VNDOCUMENT CAMERA
extension PDFController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) { //runs after scan is complete
        
        guard scan.pageCount > 0 else { //when finishing pagecount must be greater than 0 to continue")
            controller.dismiss(animated: true)
            return
        }
        showDisplayImage(image: scan.imageOfPage(at: 0)) //setting bottom uiimage in pdfController
        
        let pdfDocument = PDFDocument()
        
        for i in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: i)
            let pdfPage = PDFPage(image: image)
            pdfDocument.insert(pdfPage!, at: i)
        }
        
        savePdf(pdfDocument: pdfDocument)
        controller.dismiss(animated: true, completion: callPreview)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) { //tells delegate user canceled document scanner
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) { //tells delegate scanner failed, didn't scan
        print(error)
        dismiss(animated: true, completion: nil)
    }
}


