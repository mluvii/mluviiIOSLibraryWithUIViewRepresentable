//
//  MluviiChatLibrary.swift
//  MluviiChat
//
//  Created by Mluvi Mac on 21.03.18.
//  Copyright © 2018 Mluvii. All rights reserved.
//

import UIKit
import WebKit

public class MluviiChat: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    private var webView:WKWebView? = nil
    private var parentViewController: UIViewController!
    
    private var completeLink: String = ""
    
    typealias ChatEnded = () -> Void
    
    var endedFunc: ChatEnded? = nil
    
    var statusFunc: ((_ status: Int32) -> Void)? = nil
    
    private override init() {
        super.init()
    }
    
    public required init(fromParent viewController: UIViewController!){
        super.init()
        self.parentViewController = viewController
    }
    
    @objc private func rotated() {
        if UIDevice.current.orientation.isLandscape {
//            print("Landscape")
        }
        if UIDevice.current.orientation.isPortrait {
//            print("Portrait")
        }
        webView?.frame = CGRect(x:0, y: 0, width: parentViewController.view.bounds.size.width, height: parentViewController.view.bounds.size.height)
    }
    
    public func setChatEnded(ended: @escaping () -> Void) {
        endedFunc = ended
    }
    
    public func setStatusUpdater(statusF: @escaping (_ status: Int32) -> Void){
        statusFunc = statusF
    }
    
    public func resetUrl(){
        let url = URL(string: completeLink)!
        webView?.load(URLRequest(url:url))
        webView?.frame = CGRect(x: 0,y: 0,width: 0,height: 0)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    public func openChat(){
        guard let webView = webView else{
            print("Error :: WebView is not initialised")
            return
        }
        let openScript:String = "openChat()"
        webView.evaluateJavaScript(openScript, completionHandler: nil)
        webView.frame = parentViewController.view.frame;
        parentViewController.view.addSubview(webView)
        parentViewController.view.autoresizesSubviews = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
//    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        print("Orientation Change")
//        super.viewWillTransition(to: size, with: coordinator)
//        webView?.frame = CGRect(x:0, y: 0, width: size.width, height: size.height)
//    }
    
    public func createLink(url:String, companyGuid:String, tenantId:String, presetName:String? = nil, language:String? = nil, scope:String? = nil) -> String {
        var link: String = "https://\(url)/MobileSdkWidget?c=\(companyGuid)&t=\(tenantId)"
         var optionalPresetName = ""
         if(presetName != nil){
         optionalPresetName = "&p=\(presetName!)"
         }
        var optionalLanguage = ""
        if(language != nil){
            optionalLanguage = "&l=\(language!)"
        }
        var optionalScope = ""
        if(scope != nil){
            optionalScope = "&s=\(scope!)"
        }
        let optionalQuery = "\(optionalPresetName)\(optionalLanguage)\(optionalScope)"
//        print("optionalQuery \(optionalQuery)")
        link = "\(link)\(optionalQuery)"
        let encodedLink = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
//        print("link: \(encodedLink!)")
        completeLink = encodedLink!
        return encodedLink!
    }
    
    public func createWebView(url:String, companyGuid:String, tenantId:String, presetName:String?, language:String?, scope:String?) {
        if(webView == nil){
            let config = WKWebViewConfiguration()
            let pref = WKPreferences()
            pref.javaScriptEnabled = true
            pref.javaScriptCanOpenWindowsAutomatically = true
            let contentController = WKUserContentController()
            contentController.add(self, name: "mluviiLibrary")
            config.userContentController = contentController
            config.preferences = pref
            completeLink = createLink(url: url, companyGuid: companyGuid, tenantId: tenantId, presetName: presetName, language: language, scope: scope)
            webView = WKWebView(frame: CGRect(x: 0,y: 0,width: 0,height: 0), configuration: config)
            webView!.navigationDelegate = self
            webView!.uiDelegate = self
            let url = URL(string: completeLink)!
            webView?.load(URLRequest(url:url))
            webView?.allowsBackForwardNavigationGestures = false
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let jsonObject = message.body as! [String:AnyObject]
        if(jsonObject["type"] as! String == "status"){
            let widgetState = jsonObject["value"] as! Int32
//            print("Widget State: ", widgetState)
            statusFunc!(widgetState)
        }
        if(jsonObject["type"] as! String == "close"){
//            print("Calling ended function")
            endedFunc!()
        }
    }
    
   /*public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        //let jsonEncoder = JSONEncoder()
        //let jsonData = try jsonEncoder.encode(message.body['status'])
     
        //print("Javascript is sending message: \(String(describing: jsonObject["type"]))")
        if(jsonObject["type"] as! String == "close"){
            //minimizeView()
        }
        if(jsonObject["type"] as! String == "status"){
            let widgetState = jsonObject["value"] as! Int32
            print("Widget State: ", widgetState)
            /*if(widgetState == 0){
                OpenButton.backgroundColor = UIColor.gray
            }else if(widgetState == 1){
                OpenButton.backgroundColor = UIColor.green
            }else if(widgetState == 2){
                OpenButton.backgroundColor = UIColor.orange
            }*/
        }
        //let status = message.body.componentsSeparatedByString(":")[1]
    }*/
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error:Error){
        print(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        print("Started Loading Webview")
//        print("Start to load: "+navigation.debugDescription)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        print("Finished loading Webview")
        let script:String = "console.log('Setting window.close');var _close = window.close; window.close= function(){ if(window['webkit'] && window['webkit'].messageHandlers.mluviiLibrary) { window['webkit'].messageHandlers.mluviiLibrary.postMessage({type:'close', value: 'true'}) } }"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    public func addCustomData(name:String, value:String) {
        let script = "$owidget.addCustomData('\(name)', '\(value)')"
        webView?.evaluateJavaScript(script, completionHandler: nil)
    }
}
