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
    
    @Binding private var isOpenChatClicked: Bool
    @Binding private var buttonColor: Color

    public init(isOpenChatClicked: Binding<Bool>, buttonColor: Binding<Color>) {
         _isOpenChatClicked = isOpenChatClicked
        _buttonColor = buttonColor
     }

    public func makeUIView(context: Context) -> UIViewType {
        let chat = MluviiChat()
        chat.setStatusUpdater(statusF: statusUpdate)
        let chatView = chat.createUIView(url: "ptr.mluvii.com", companyGuid: "295b1064-cf5b-4a5d-9e05-e7a74f86ae5e", tenantId: "1", presetName: nil, language: nil, scope: nil)
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
    
    private func statusUpdate(status: Int32) -> Void{
        print("Update status \(status)")
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
