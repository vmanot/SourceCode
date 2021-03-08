//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)

import SwiftUIX
import WebKit

public class ACEJSWebView: _WKWebView {
    private struct Constants {
        static let aceEditorDidReady = "aceEditorDidReady"
        static let aceEditorDidChange = "aceEditorDidChange"
    }
    
    private var text = String()
    private var currentTheme: Theme?
    
    var onTextChange: ((String) -> Void)?
    
    public var themeForLightMode: Theme = .solarized_light
    public var themeForDarkMode: Theme = .solarized_dark
    
    var preferredColorScheme: ColorScheme = .light {
        didSet {
            guard preferredColorScheme != oldValue else {
                return
            }
            
            preferredColorScheme == .dark ? setTheme(themeForDarkMode) : setTheme(themeForLightMode)
        }
    }
    
    private var pageLoaded = false
    private var pendingFunctions = [JavascriptFunction]()
    
    public init() {
        super.init(frame: .zero, configuration: Self.makeConfiguration())
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private static func makeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        configuration.preferences = WKPreferences()
        configuration.userContentController = userContentController
        
        return configuration
    }
    
    private func setup() {
        configuration.userContentController.add(self, name: Constants.aceEditorDidReady)
        configuration.userContentController.add(self, name: Constants.aceEditorDidChange)
        
        navigationDelegate = self
        
        #if os(macOS)
        setValue(true, forKey: "drawsTransparentBackground") // Prevent white flick
        #elseif os(iOS)
        isOpaque = false
        #endif
        
        guard let bundlePath = Bundle.module.path(forResource: "ace", ofType: "bundle"),
              let bundle = Bundle(path: bundlePath),
              let indexPath = bundle.path(forResource: "index", ofType: "html") else {
            fatalError("Ace editor is missing")
        }
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: indexPath))
        
        load(data, mimeType: "text/html", characterEncodingName: "utf-8", baseURL: bundle.resourceURL!)
        
        callJavascript(javascriptString: "editor.setOptions({ maxLines: Infinity });")
    }
    
    func setText(_ value: String) {
        guard text != value else {
            return
        }
        
        text = value
        
        //
        // It's tricky to pass FULL JSON or HTML text with \n or "", ... into JS Bridge
        // Have to wrap with `data_here`
        // And use String.raw to prevent escape some special string -> String will show exactly how it's
        // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Template_literals
        //
        let first = "var content = String.raw`"
        let content = """
        \(value)
        """
        let end = "`; editor.setValue(content);"
        
        let script = first + content + end
        
        callJavascript(javascriptString: script)
    }
    
    func setTheme(_ theme: Theme) {
        callJavascript(javascriptString: "editor.setTheme('ace/theme/\(theme.rawValue)');")
    }
    
    func setMode(_ mode: Mode) {
        callJavascript(javascriptString: "editor.session.setMode('ace/mode/\(mode.rawValue)');")
    }
    
    func setReadOnly(_ isReadOnly: Bool) {
        callJavascript(javascriptString: "editor.setReadOnly(\(isReadOnly));")
    }
    
    func setFontSize(_ fontSize: Int) {
        let script = "document.getElementById('editor').style.fontSize='\(fontSize)px';"
        callJavascript(javascriptString: script)
    }
    
    func clearSelection() {
        let script = "editor.clearSelection();"
        callJavascript(javascriptString: script)
    }
    
    fileprivate func getAnnotation(callback: @escaping JavascriptFunction.Callback) {
        let script = "editor.getSession().getAnnotations();"
        callJavascript(javascriptString: script) { result in
            callback(result)
        }
    }
}

extension ACEJSWebView {
    private func addFunction(function:JavascriptFunction) {
        pendingFunctions.append(function)
    }
    
    private func callJavascriptFunction(function: JavascriptFunction) {
        evaluateJavaScript(function.functionString) { (response, error) in
            if let error = error {
                function.callback?(.failure(error))
            }
            else {
                function.callback?(.success(response))
            }
        }
    }
    
    private func callPendingFunctions() {
        for function in pendingFunctions {
            callJavascriptFunction(function: function)
        }
        pendingFunctions.removeAll()
    }
    
    private func callJavascript(
        javascriptString: String,
        callback: JavascriptFunction.Callback? = nil
    ) {
        if pageLoaded {
            callJavascriptFunction(function: JavascriptFunction(functionString: javascriptString, callback: callback))
        }
        else {
            addFunction(function: JavascriptFunction(functionString: javascriptString, callback: callback))
        }
    }
}

// MARK: - Protocol Conformances -

extension ACEJSWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

extension ACEJSWebView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.aceEditorDidReady {
            pageLoaded = true
            callPendingFunctions()
        } else if message.name == Constants.aceEditorDidChange {
            if let text = message.body as? String, self.text != text {
                self.text = text
                
                self.onTextChange?(text)
            }
        }
    }
}

extension ACEJSWebView {
    public enum Theme: String {
        case ambiance = "ambiance"
        case chrome = "chrome"
        case clouds = "clouds"
        case clouds_midnight = "clouds_midnight"
        case cobalt = "cobalt"
        case crimson_editor = "crimson_editor"
        case dawn = "dawn"
        case dracula = "dracula"
        case dreamweaver = "dreamweaver"
        case chaos = "chaos"
        case eclipse = "eclipse"
        case github = "github"
        case gob = "gob"
        case gruvbox = "gruvbox"
        case idle_fingers = "idle_fingers"
        case iplastic = "iplastic"
        case katzenmilch = "katzenmilch"
        case kr_theme = "kr_theme"
        case kuroir = "kuroir"
        case merbivore = "merbivore"
        case merbivore_soft = "merbivore_soft"
        case mono_industrial = "mono_industrial"
        case monokai = "monokai"
        case nord_dark = "nord_dark"
        case pastel_on_dark = "pastel_on_dark"
        case solarized_dark = "solarized_dark"
        case solarized_light = "solarized_light"
        case sqlserver = "sqlserver"
        case terminal = "terminal"
        case textmate = "textmate"
        case tomorrow = "tomorrow"
        case tomorrow_night = "tomorrow_night"
        case tomorrow_night_blue = "tomorrow_night_blue"
        case tomorrow_night_bright = "tomorrow_night_bright"
        case tomorrow_night_eighties = "tomorrow_night_eighties"
        case twilight = "twilight"
        case vibrant_ink = "vibrant_ink"
        case xcode = "xcode"
    }
    
    public enum Mode: String {
        case abap = "abap"
        case abc = "abc"
        case actionscript = "actionscript"
        case ada = "ada"
        case alda = "alda"
        case apache_conf = "apache_conf"
        case apex = "apex"
        case applescript = "applescript"
        case aql = "aql"
        case asciidoc = "asciidoc"
        case asl = "asl"
        case assembly_x86 = "assembly_x86"
        case autohotkey = "autohotkey"
        case batchfile = "batchfile"
        case c9search = "c9search"
        case c_cpp = "c_cpp"
        case cirru = "cirru"
        case clojure = "clojure"
        case cobol = "cobol"
        case coffee = "coffee"
        case coldfusion = "coldfusion"
        case crystal = "crystal"
        case csharp = "csharp"
        case csound_document = "csound_document"
        case csound_orchestra = "csound_orchestra"
        case csound_score = "csound_score"
        case csp = "csp"
        case css = "css"
        case curly = "curly"
        case d = "d"
        case dart = "dart"
        case diff = "diff"
        case django = "django"
        case dockerfile = "dockerfile"
        case dot = "dot"
        case drools = "drools"
        case edifact = "edifact"
        case eiffel = "eiffel"
        case ejs = "ejs"
        case elixir = "elixir"
        case elm = "elm"
        case erlang = "erlang"
        case forth = "forth"
        case fortran = "fortran"
        case fsharp = "fsharp"
        case fsl = "fsl"
        case ftl = "ftl"
        case gcode = "gcode"
        case gherkin = "gherkin"
        case gitignore = "gitignore"
        case glsl = "glsl"
        case gobstones = "gobstones"
        case golang = "golang"
        case graphqlschema = "graphqlschema"
        case groovy = "groovy"
        case haml = "haml"
        case handlebars = "handlebars"
        case haskell = "haskell"
        case haskell_cabal = "haskell_cabal"
        case haxe = "haxe"
        case hjson = "hjson"
        case html = "html"
        case html_elixir = "html_elixir"
        case html_ruby = "html_ruby"
        case ini = "ini"
        case io = "io"
        case jack = "jack"
        case jade = "jade"
        case java = "java"
        case javascript = "javascript"
        case json = "json"
        case json5 = "json5"
        case jsoniq = "jsoniq"
        case jsp = "jsp"
        case jssm = "jssm"
        case jsx = "jsx"
        case julia = "julia"
        case kotlin = "kotlin"
        case latex = "latex"
        case less = "less"
        case liquid = "liquid"
        case lisp = "lisp"
        case livescript = "livescript"
        case logiql = "logiql"
        case logtalk = "logtalk"
        case lsl = "lsl"
        case lua = "lua"
        case luapage = "luapage"
        case lucene = "lucene"
        case makefile = "makefile"
        case markdown = "markdown"
        case mask = "mask"
        case matlab = "matlab"
        case maze = "maze"
        case mediawiki = "mediawiki"
        case mel = "mel"
        case mixal = "mixal"
        case mushcode = "mushcode"
        case mysql = "mysql"
        case nginx = "nginx"
        case nim = "nim"
        case nix = "nix"
        case nsis = "nsis"
        case nunjucks = "nunjucks"
        case objectivec = "objectivec"
        case ocaml = "ocaml"
        case pascal = "pascal"
        case perl = "perl"
        case perl6 = "perl6"
        case pgsql = "pgsql"
        case php = "php"
        case php_laravel_blade = "php_laravel_blade"
        case pig = "pig"
        case plain_text = "plain_text"
        case powershell = "powershell"
        case praat = "praat"
        case prisma = "prisma"
        case prolog = "prolog"
        case properties = "properties"
        case protobuf = "protobuf"
        case puppet = "puppet"
        case python = "python"
        case qml = "qml"
        case r = "r"
        case razor = "razor"
        case rdoc = "rdoc"
        case red = "red"
        case redshift = "redshift"
        case rhtml = "rhtml"
        case rst = "rst"
        case ruby = "ruby"
        case rust = "rust"
        case sass = "sass"
        case scad = "scad"
        case scala = "scala"
        case scheme = "scheme"
        case scss = "scss"
        case sh = "sh"
        case sjs = "sjs"
        case slim = "slim"
        case smarty = "smarty"
        case snippets = "snippets"
        case soy_template = "soy_template"
        case space = "space"
        case sparql = "sparql"
        case sql = "sql"
        case sqlserver = "sqlserver"
        case stylus = "stylus"
        case svg = "svg"
        case swift = "swift"
        case tcl = "tcl"
        case terraform = "terraform"
        case tex = "tex"
        case text = "text"
        case textile = "textile"
        case toml = "toml"
        case tsx = "tsx"
        case turtle = "turtle"
        case twig = "twig"
        case typescript = "typescript"
        case vala = "vala"
        case vbscript = "vbscript"
        case velocity = "velocity"
        case verilog = "verilog"
        case vhdl = "vhdl"
        case visualforce = "visualforce"
        case wollok = "wollok"
        case xml = "xml"
        case xquery = "xquery"
        case yaml = "yaml"
        case zeek = "zeek"
    }
}

extension ACEJSWebView {
    public struct Annotation: Decodable {
        enum AnnotationType: String, Decodable {
            case error
            case warning
            case info
        }
        
        let column: Int
        let row: Int
        let text: String
        let type: AnnotationType
        
        init?(from dictionary: [String: Any]) {
            guard
                let column = dictionary["column"] as? Int,
                let row = dictionary["row"] as? Int,
                let text = dictionary["text"] as? String,
                let typeRaw = dictionary["type"] as? String,
                let type = AnnotationType(rawValue: typeRaw) else {
                return nil
            }
            
            self.column = column
            self.row = row
            self.text = text
            self.type = type
        }
    }
}

// MARK: - Auxiliary Implementation -

private struct JavascriptFunction {
    typealias Callback = (Result<Any?, Error>) -> Void
    
    let functionString: String
    let callback: Callback?
    
    init(functionString: String, callback: Callback? = nil) {
        self.functionString = functionString
        self.callback = callback
    }
}

#endif
