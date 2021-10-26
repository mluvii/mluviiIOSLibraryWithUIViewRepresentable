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
    
    private var completeLink: String = ""
    
    typealias ChatEnded = () -> Void
    
    var endedFunc: ChatEnded? = nil
    
    var statusFunc: ((_ status: Int32) -> Void)? = nil
    
    public override init() {
        super.init()
    }
    
    @objc private func rotated() {
        if UIDevice.current.orientation.isLandscape {
//            print("Landscape")
        }
        if UIDevice.current.orientation.isPortrait {
//            print("Portrait")
        }
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
    }
    
    public func openChat(){
        guard let webView = webView else{
            print("Error :: WebView is not initialised")
            return
        }
        let openScript:String = "openChat()"
        webView.evaluateJavaScript(openScript, completionHandler: nil)
    }
    
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
    
    public func createUIView(url:String, companyGuid:String, tenantId:String, presetName:String?, language:String?, scope:String?) -> WKWebView {
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
            webView = WKWebView(frame: .zero, configuration: config)
            webView!.navigationDelegate = self
            webView!.uiDelegate = self
            let url = URL(string: completeLink)!
            webView?.load(URLRequest(url:url))
            webView?.allowsBackForwardNavigationGestures = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.openChat()
            }
        }
        return webView ?? WKWebView()
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
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error:Error){
        print(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        print("Started Loading Webview")
//        print("Start to load: "+navigation.debugDescription)
//        print("Start to load: " + (webView.url?.absoluteString ?? "Empty URL"))
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
