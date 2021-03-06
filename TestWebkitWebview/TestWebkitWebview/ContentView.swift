//
//  ContentView.swift
//  TestWebkitWebview
//
//  Created by Maulik Bhuptani on 24/10/21.
//

import SwiftUI
import WebKit
import MluviiChat

struct ContentView: View {
    
    @State private var isOpenChatClicked: Bool = false
    @State private var buttonColor: Color = .clear

    var body: some View {
        return ZStack {
            Button(action: {
                isOpenChatClicked = true
            }){
                Text("Open Chat").background(buttonColor)
            }
            if isOpenChatClicked{
                MluviiChatView(isOpenChatClicked: $isOpenChatClicked, buttonColor: $buttonColor)
            }
        }
    }
}

struct MluviiChatView: UIViewRepresentable {
    
    typealias Context = UIViewRepresentableContext<Self>
    typealias UIViewType = WKWebView
    
    public var chat = MluviiChatLibrary()
    @Binding private var isOpenChatClicked: Bool
    @Binding private var buttonColor: Color

    public init(isOpenChatClicked: Binding<Bool>, buttonColor: Binding<Color>) {
         _isOpenChatClicked = isOpenChatClicked
        _buttonColor = buttonColor
     }

    public func makeUIView(context: Context) -> UIViewType {
        chat.setStatusUpdater(statusF: statusUpdate)
        let chatView = chat.createUIView(
            url: "apptest.mluvii.com",
            companyGuid: "295b1064-cf5b-4a5d-9e05-e7a74f86ae5e",
            tenantId: "1",
            presetName: nil,
            language: nil,
            scope: nil,
            navigationActionCustomDelegate: self.navigationActionDelegate
        )
        chat.setChatEnded {
            isOpenChatClicked = false
            chat.resetUrl()
        }
        
        return chatView
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if isOpenChatClicked{
            uiView.isHidden = false
        }else{
            uiView.isHidden = true
        }
    }
    
    public func navigationActionDelegate(webView: WKWebView, navigationAction: WKNavigationAction) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
          if url.description.lowercased().range(of: "http://") != nil ||
            url.description.lowercased().range(of: "https://") != nil ||
            url.description.lowercased().range(of: "mailto:") != nil {
            UIApplication.shared.openURL(url)
          }
        }
      return nil
    }
    
    private func statusUpdate(status: Int32) -> Void{
        print("Update status \(status)")
        chat.addCustomData(name: "Puvod", value: "mobil-test")
        chat.openChat()
        let widgetState = status
        if(widgetState == 0){
            buttonColor = .gray
        }else if(widgetState == 1){
            buttonColor = .green
        }else if(widgetState == 2){
            buttonColor = .orange
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
