//
// Copyright (c) Vatsal Manot
//

import SwiftUIX
import WebKit

public struct CodeEditor: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = ACEJSWebView
    
    @Binding var text: String
    
    var onEditingChanged: ((String) -> Void)?
    
    private let mode: ACEJSWebView.Mode
    private let darkTheme: ACEJSWebView.Theme
    private let lightTheme: ACEJSWebView.Theme
    private let fontSize: Int
    
    public init(
        text: Binding<String>,
        mode: ACEJSWebView.Mode = .json,
        darkTheme: ACEJSWebView.Theme = .solarized_dark,
        lightTheme: ACEJSWebView.Theme = .solarized_light,
        fontSize: Int = 12,
        onEditingChanged: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.mode = mode
        self.darkTheme = darkTheme
        self.lightTheme = lightTheme
        self.fontSize = fontSize
        self.onEditingChanged = onEditingChanged
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        let appKitOrUIKitView = ACEJSWebView()
        
        appKitOrUIKitView.setReadOnly(!context.environment.isEnabled)
        appKitOrUIKitView.setMode(mode)
        appKitOrUIKitView.setFontSize(fontSize)
        appKitOrUIKitView.setContent(text)
        appKitOrUIKitView.clearSelection()
        
        context.environment.colorScheme == .dark
            ? appKitOrUIKitView.setTheme(darkTheme)
            : appKitOrUIKitView.setTheme(lightTheme)
        
        return appKitOrUIKitView
    }
    
    public func updateAppKitOrUIKitView(_ appKitOrUIKitView: AppKitOrUIKitViewType, context: Context) {
        appKitOrUIKitView.onTextChange = { text in
            if text != self.text {
                self.text = text
            }
            
            self.onEditingChanged?(text)
        }
        
        #if os(iOS) || os(tvOS)
        appKitOrUIKitView.isUserInteractionEnabled = context.environment.isEnabled
        #endif
        
        appKitOrUIKitView.isScrollEnabled = context.environment.isScrollEnabled
        
        if !(context.coordinator.colorScheme == context.environment.colorScheme) {
            context.environment.colorScheme == .dark ? appKitOrUIKitView.setTheme(darkTheme) : appKitOrUIKitView.setTheme(lightTheme)
            
            context.coordinator.set(colorScheme: context.environment.colorScheme)
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

public extension CodeEditor {
    class Coordinator: NSObject {
        private(set) var colorScheme: ColorScheme?
        
        func set(colorScheme: ColorScheme) {
            if self.colorScheme != colorScheme {
                self.colorScheme = colorScheme
            }
        }
    }
}

struct CodeEditor_Previews: PreviewProvider {
    static private var jsonString = """
    {
        "hello": "world"
    }
    """
    
    static var previews: some View {
        CodeEditor(text: .constant(jsonString))
    }
}
