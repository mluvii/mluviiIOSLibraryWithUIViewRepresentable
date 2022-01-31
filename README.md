# iOS

Mluvii provides a framework for integration with your application. The code provided by us enables you to:

- initiate a webview with a widget with your company data
- notification on change of widget status
- open chat
- close the chat and load a page with widget

#### Known issue: Due to the unavailability of getUserMedia in in-app WkWebView, video will not connect in Application

If a project downloaded from GitHub does not run because the `MluviiChat` framework cannot be found, we recommend that you recompile the `MluviiChat` project and replace the `MluviiChat.framework` file in the `TestWebkitWebview` project with the newly created `MluviiChat.framework` file.

For best user experience you should add following permissions to your info.plist:

```
1. Privacy - Camera usage Description
2. Privacy - Microphone usage Description
3. Privacy - Media Library Usage Description
```

If you will not add `Media Library Usage Description` app will crash when user tries to upload file in mluvii chat

More info on [Apple Developer Portal](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy/requesting_access_to_protected_resources)

Sample Code:

```
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
```

[ContentView.swift](https://github.com/mluvii/mluviiIOSLibraryWithUIViewRepresentable/blob/main/TestWebkitWebview/TestWebkitWebview/ContentView.swift)
