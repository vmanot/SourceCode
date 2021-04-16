//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import Foundation
import SwiftUIX
import WebKit

// See https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/AdoptingCocoaDesignPatterns.html for more details.
private var observerContext = 0

open class _WKWebView: WKWebView {
    public var isScrollEnabled: Bool = true {
        didSet {
            #if os(iOS)
            self.scrollView.isScrollEnabled = isScrollEnabled
            #endif
        }
    }
    
    private var estimatedContentSize: OptionalDimensions = nil {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        .init(
            width: super.intrinsicContentSize.width,
            height: estimatedContentSize.height ?? super.intrinsicContentSize.height
        )
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: &observerContext)
        
        #if os(iOS)
        scrollView.isScrollEnabled = false
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        #endif
        
        evaluateAndSizeToFit()
    }
    
    #if os(macOS)
    override open func scrollWheel(with event: NSEvent) {
        guard isScrollEnabled else {
            if let nextResponder = nextResponder {
                nextResponder.scrollWheel(with: event)
            }
            
            return
        }
        
        super.scrollWheel(with: event)
    }
    #endif
    
    open func evaluateAndSizeToFit() {
        evaluateJavaScript("document.readyState", completionHandler: { result, error in
            if result == nil || error != nil {
                return
            }
            
            self.evaluateJavaScript("document.getElementsByTagName('html')[0].scrollHeight", completionHandler: { result, error in                self.estimatedContentSize.height = result as? CGFloat ?? 0.0
            })
        })
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: &observerContext)
    }
}

extension _WKWebView {
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &observerContext {
            if let _ = change?[.newKey] as? Double {
                guard self.estimatedProgress > 0.5 else {
                    return
                }
                                
                evaluateJavaScript("document.getElementsByTagName('html')[0].scrollHeight", completionHandler: { result, error in
                    self.estimatedContentSize.height = result as? CGFloat ?? 0.0
                })
            }
            
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

#endif
