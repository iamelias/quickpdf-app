//
//  PdfPreviewController.swift
//  PDFCreator
//
//  Created by Elias Hall on 6/15/20.
//  Copyright © 2020 Elias Hall. All rights reserved.
//

import Foundation
import UIKit
import PDFKit

class PdfPreviewController: UIViewController {
    public var passedURL: URL?
    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let passedURL = passedURL else { // early return if passedURL is nil
            return
        }
        
        setUpDocument(passedURL: passedURL)
    }
    
    @IBAction func shareButton(_ sender: Any) { //calls activity controller
        guard let passedURL = passedURL else {return}
        let vc = UIActivityViewController(activityItems: [passedURL], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    func setUpDocument(passedURL: URL) {
        let pdfDocument = PDFDocument(url: passedURL)
        
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: passedURL.path) {
            pdfView.document = PDFDocument(url: passedURL)
        }
    }
}
