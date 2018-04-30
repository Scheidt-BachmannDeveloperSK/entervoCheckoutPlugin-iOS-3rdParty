//
//  ViewController.swift
//  plugin3rdparty
//
//  Created by Developer on 18.12.17.
//  Copyright © 2017 Scheidt & Bachmann. All rights reserved.
//

import UIKit
import entervoCheckoutPlugin

class ViewController: UIViewController, SBCheckOutDelegate {
    
    private let USE_CUSTOM_STYLE = true
    private var sessionToken : String?
    private var userDidPay = false
    
    @IBOutlet var pluginArea: UIView!
    
    func onMessage(level: SBCheckOut.LogLevel, message: String) {
        NSLog( "onMessage: \(message)")
    }
    
    func onError(message: String) {
        NSLog( "onError: \(message)")
    }
    
    func onStatus(newStatus: SBCheckOut.Status, info: Any?) {
        NSLog( "onStatus: \(newStatus)")
        if ( newStatus == .FLOW_FINISHED) {
            showReceipt(data: info)
        }
    }
    
    func onConductPayment(sessionToken: String) {
        
        self.sessionToken = sessionToken
        NSLog( "onConductPayment: \(sessionToken)")
        askForDemoPaymentResult()
    }
    
    func askForDemoPaymentResult() {
        let dlg = UIAlertController( title: "Demo Payment", message: "Select the desired demo payment outcome", preferredStyle: .alert)
        let successAction = UIAlertAction( title: "PAID", style: .default) {
            (action: UIAlertAction!) in
            self.userDidPay = true
            plugin.postPayment(sessionToken: self.sessionToken!, transactionReference: "TXN000")
        }
        
        let failAction = UIAlertAction( title: "FAILED", style: .default) {
            (action: UIAlertAction!) in
            self.userDidPay = false
            plugin.cancelPayment(sessionToken: self.sessionToken!)
        }
        
        dlg.addAction(successAction)
        dlg.addAction(failAction)
        self.present( dlg, animated: true, completion: nil)
    }
    
    
    @IBAction func startFlow() {
        // start the plugin flow (with a demo ticket)
        self.userDidPay = false
        plugin.start( identification: "869954023633772111", type: .BARCODE)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plugin.setDelegate(self);               // this viewcontroller is the delegate for the plugin
        plugin.setLogLevel(level: .TRACE)       // in the first place, the plugin shall be "chatty"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // define the area in which to present the plugin screens
        plugin.setRect( self.pluginArea.frame)
        
        if ( USE_CUSTOM_STYLE) {
            plugin.setAsset(image: UIImage(named: "myhappy")!, for: .IMAGE_SUCCESS)
            plugin.setAsset(image: UIImage(named: "mysad")!, for: .IMAGE_FAIL)
            plugin.setAsset(image: UIImage(named: "mybackground.jpg")!, for: .IMAGE_BACKGROUND)
            plugin.setAsset(contents: styleSheetAsString(name: "mystyles"), for: .STYLESHEET)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showReceipt( data: Any?) {
        var receiptText = "No transaction was concluded."
        if let receipt = data as? SBCheckOutTransaction {

            if ( userDidPay && receipt.success) {
                receiptText =
                    "transaction time: " + receipt.transaction_time + "\n" +
                    "transaction id: " + receipt.unique_pay_id + "\n" +
                    "facility: " + receipt.facility_name + "\n" +
                    "ticket: " + receipt.epan + "\n" +
                    "total amount: \(receipt.amount) \(receipt.currency)\n" +
                    "including VAT of\(receipt.vat_rate) = \(receipt.vat_amount) \(receipt.currency)\n"
            }
        }
        let confirmation = UIAlertController(title: "*** YOUR RECEIPT ***", message: receiptText, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        confirmation.addAction(ok)
        self.present( confirmation, animated: true, completion: nil)
    }
    
    func styleSheetAsString( name: String) -> String {
        var style = ""
        let path = Bundle.main.path(forResource: name, ofType: "css")
        do {
            style = try String( contentsOfFile: path!, encoding: String.Encoding.utf8)
        } catch {}
        return style
    }
}
