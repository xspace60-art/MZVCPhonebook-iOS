import SwiftUI
import WebKit

// MARK: - Phonebook Web Container View
/// Main entry container that displays http://129.225.98.64/phonebook/
/// Features:
/// 1. Direct Call: Instantly dials phone numbers via iOS Phone app (tel://) with haptic feedback.
/// 2. WhatsApp: Opens WhatsApp chat directly with polite prefilled Mizo greeting (whatsapp://).
/// 3. Copy: Copies number to clipboard with native haptic feedback and toast banner.
/// 4. Report Incorrect Info: Submit wrong numbers, expired terms, or spelling mistakes directly to District Administrator.
/// 5. Responsive Optimization: Adaptive scaling across iPhone SE (compact), Pro Max, and iPad screens.
public struct PhonebookWebContainerView: View {
    @StateObject private var webState = WebViewState()
    @StateObject private var store = PhonebookStore()
    @State private var showOfflineDirectory: Bool = false
    @State private var showReportCorrection: Bool = false
    @State private var showShareSheet: Bool = false
    
    private let phonebookURL = URL(string: "http://129.225.98.64/phonebook/")!

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            let isCompact = geo.size.width < 380 // iPhone SE & small screens
            let isPad = geo.size.width >= 768    // iPad & landscape screens

            ZStack(alignment: .bottom) {
                // Background matching web app header for seamless status bar blend
                Color(red: 0.07, green: 0.36, blue: 0.50)
                    .ignoresSafeArea()

                // Main Web View
                PhonebookWebViewRepresentable(state: webState, targetURL: phonebookURL)
                    .ignoresSafeArea(.container, edges: .all)

                // Top Progress Bar
                VStack(spacing: 0) {
                    if webState.isLoading && webState.progress < 1.0 {
                        GeometryReader { progressGeo in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.07, green: 0.36, blue: 0.50), Color(red: 0.06, green: 0.72, blue: 0.51)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: progressGeo.size.width * CGFloat(webState.progress), height: 3.5)
                                .animation(.easeOut(duration: 0.2), value: webState.progress)
                        }
                        .frame(height: 3.5)
                    }
                    Spacer()
                }
                .ignoresSafeArea(.container, edges: .top)

                // Native Toast HUD for Copy & Direct Actions
                VStack {
                    if let toast = webState.toastMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 15))
                            Text(toast)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.88))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, isPad ? 30 : 54)
                    }
                    Spacer()
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: webState.toastMessage)
                .ignoresSafeArea(.container, edges: .top)

                // Offline / Connection Error Overlay
                if webState.hasError {
                    VStack(spacing: 18) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 46, weight: .semibold))
                            .foregroundColor(Color(red: 0.07, green: 0.36, blue: 0.50))

                        VStack(spacing: 6) {
                            Text("Connection Offline")
                                .font(.system(size: 19, weight: .bold))

                            Text("Unable to reach the live phonebook at\nhttp://129.225.98.64/phonebook/\nPlease check your network connection.")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }

                        HStack(spacing: 12) {
                            Button(action: {
                                webState.reload()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Retry")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 18)
                                .background(Color(red: 0.07, green: 0.36, blue: 0.50))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }

                            Button(action: {
                                showOfflineDirectory = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "folder.badge.person.crop")
                                    Text("Offline Directory")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 18)
                                .background(Color(.secondarySystemFill))
                                .foregroundColor(.primary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(22)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 8)
                    )
                    .padding(24)
                    .transition(.opacity.combined(with: .scale))
                }

                // Adaptive Floating Action Capsule
                if !webState.hasError {
                    HStack(spacing: isCompact ? 10 : 16) {
                        // Back Navigation
                        Button(action: {
                            webState.goBack()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: isCompact ? 14 : 15, weight: .bold))
                                .foregroundColor(webState.canGoBack ? .primary : .secondary.opacity(0.35))
                        }
                        .disabled(!webState.canGoBack)

                        // Forward Navigation
                        Button(action: {
                            webState.goForward()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: isCompact ? 14 : 15, weight: .bold))
                                .foregroundColor(webState.canGoForward ? .primary : .secondary.opacity(0.35))
                        }
                        .disabled(!webState.canGoForward)

                        Divider()
                            .frame(height: 16)

                        // Reload Button
                        Button(action: {
                            webState.reload()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        // Share Portal Link
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: isCompact ? 14 : 15, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        Divider()
                            .frame(height: 16)

                        // Report Incorrect Info (Direct to District Admin)
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showReportCorrection = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: isCompact ? 11 : 12))
                                    .foregroundColor(.orange)
                                if !isCompact {
                                    Text("Report")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                            }
                        }

                        Divider()
                            .frame(height: 16)

                        // Saved Favorites & Offline Directory
                        Button(action: {
                            showOfflineDirectory = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: isCompact ? 11 : 12))
                                    .foregroundColor(Color(red: 0.07, green: 0.36, blue: 0.50))
                                if !isCompact {
                                    Text("Saved")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(red: 0.07, green: 0.36, blue: 0.50))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, isCompact ? 12 : 18)
                    .padding(.vertical, isCompact ? 8 : 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                    .frame(maxWidth: isPad ? 440 : .infinity)
                    .padding(.bottom, isCompact ? 8 : 14)
                }
            }
        }
        .environmentObject(store)
        .sheet(isPresented: $showOfflineDirectory) {
            MainTabView()
                .environmentObject(store)
        }
        .sheet(isPresented: $showReportCorrection) {
            ReportCorrectionSheet()
                .environmentObject(store)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [phonebookURL])
        }
    }
}

// MARK: - Observable Web State
public final class WebViewState: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var canGoBack: Bool = false
    @Published public var canGoForward: Bool = false
    @Published public var hasError: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var toastMessage: String? = nil

    fileprivate var webViewReference: WKWebView? = nil

    public func reload() {
        hasError = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        webViewReference?.reload()
    }

    public func goBack() {
        if webViewReference?.canGoBack == true {
            webViewReference?.goBack()
        }
    }

    public func goForward() {
        if webViewReference?.canGoForward == true {
            webViewReference?.goForward()
        }
    }

    public func showToast(_ msg: String) {
        toastMessage = msg
        Task {
            try? await Task.sleep(nanoseconds: 2_600_000_000)
            await MainActor.run {
                if self.toastMessage == msg {
                    self.toastMessage = nil
                }
            }
        }
    }
}

// MARK: - UIViewRepresentable for WKWebView
public struct PhonebookWebViewRepresentable: UIViewRepresentable {
    @ObservedObject var state: WebViewState
    let targetURL: URL

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        // User script: Injects native hooks into copy actions
        let scriptSource = """
        (function() {
            // Hook into copyContact function
            const origCopy = window.copyContact;
            window.copyContact = function(name, phone) {
                try {
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeActions) {
                        window.webkit.messageHandlers.nativeActions.postMessage({
                            action: 'copy',
                            name: name || 'Contact',
                            phone: phone || ''
                        });
                    }
                } catch(e) {}
                if (typeof origCopy === 'function') {
                    origCopy(name, phone);
                }
            };

            // Hook into navigator.clipboard.writeText
            if (navigator.clipboard && navigator.clipboard.writeText) {
                const origWrite = navigator.clipboard.writeText.bind(navigator.clipboard);
                navigator.clipboard.writeText = function(text) {
                    try {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeActions) {
                            window.webkit.messageHandlers.nativeActions.postMessage({
                                action: 'copy',
                                name: 'Number',
                                phone: text
                            });
                        }
                    } catch(e) {}
                    return origWrite(text);
                };
            }
        })();
        """

        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)
        configuration.userContentController.add(context.coordinator, name: "nativeActions")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.decelerationRate = .normal // 120Hz smooth scrolling
        webView.backgroundColor = UIColor(red: 0.07, green: 0.36, blue: 0.50, alpha: 1.0)
        webView.scrollView.backgroundColor = UIColor(red: 0.07, green: 0.36, blue: 0.50, alpha: 1.0)

        // Custom User Agent identifier
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MZVCPhonebook-iOS/2.4.0"

        // Pull to refresh support
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        // Store reference in state
        state.webViewReference = webView

        // Setup estimatedProgress and navigation state observers
        context.coordinator.setupObservers(for: webView)

        // Load the phonebook URL
        let request = URLRequest(url: targetURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15.0)
        webView.load(request)

        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        let parent: PhonebookWebViewRepresentable
        private var progressObservation: NSKeyValueObservation?
        private var backObservation: NSKeyValueObservation?
        private var forwardObservation: NSKeyValueObservation?

        init(_ parent: PhonebookWebViewRepresentable) {
            self.parent = parent
            super.init()
        }

        func setupObservers(for webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.state.progress = webView.estimatedProgress
                }
            }

            backObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.state.canGoBack = webView.canGoBack
                }
            }

            forwardObservation = webView.observe(\.canGoForward, options: [.new]) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.state.canGoForward = webView.canGoForward
                }
            }
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {
            parent.state.reload()
        }

        // Script Message Handler for Native Copy with Haptic Feedback
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "nativeActions",
                  let dict = message.body as? [String: Any],
                  let action = dict["action"] as? String else { return }

            if action == "copy" {
                let phone = dict["phone"] as? String ?? ""
                let name = dict["name"] as? String ?? "Number"
                if !phone.isEmpty {
                    UIPasteboard.general.string = phone
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    parent.state.showToast("📋 Copied: \(name) (\(phone))")
                }
            }
        }

        // Intercept URLs: Direct Call (tel://), WhatsApp (whatsapp://), mailto, sms
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let scheme = url.scheme?.lowercased() ?? ""

            // 1. Direct Call: Instantly dial via iOS Phone app (tel://)
            if scheme == "tel" || scheme == "telprompt" {
                let raw = url.absoluteString
                    .replacingOccurrences(of: "telprompt://", with: "")
                    .replacingOccurrences(of: "telprompt:", with: "")
                    .replacingOccurrences(of: "tel://", with: "")
                    .replacingOccurrences(of: "tel:", with: "")
                let cleanDigits = raw.filter { $0.isNumber || $0 == "+" }
                if let telURL = URL(string: "tel://\(cleanDigits)"), UIApplication.shared.canOpenURL(telURL) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    UIApplication.shared.open(telURL, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }

            // 2. WhatsApp: Opens WhatsApp chat with polite prefilled Mizo greeting (whatsapp://)
            if scheme == "whatsapp" || url.host?.contains("whatsapp.com") == true || url.host?.contains("wa.me") == true {
                var waPhone = ""
                var waMessage = ""

                if url.host?.contains("wa.me") == true {
                    waPhone = url.path.replacingOccurrences(of: "/", with: "").filter { $0.isNumber }
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        waMessage = components.queryItems?.first(where: { $0.name == "text" })?.value ?? ""
                    }
                } else if url.host?.contains("whatsapp.com") == true {
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        waPhone = (components.queryItems?.first(where: { $0.name == "phone" })?.value ?? "").filter { $0.isNumber }
                        waMessage = components.queryItems?.first(where: { $0.name == "text" })?.value ?? ""
                    }
                }

                // If phone is 10 digits without country code, prepend 91 for India
                if waPhone.count == 10 {
                    waPhone = "91\(waPhone)"
                }

                // Ensure polite Mizo greeting is attached
                if waMessage.isEmpty {
                    waMessage = "Chibai, khawngaih in ka be thei che angem."
                }

                let encodedText = waMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let nativeWaURL = URL(string: "whatsapp://send?phone=\(waPhone)&text=\(encodedText)"),
                   UIApplication.shared.canOpenURL(nativeWaURL) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    UIApplication.shared.open(nativeWaURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback to web link if WhatsApp application is not installed
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }

            // 3. Mail and SMS
            if scheme == "mailto" || scheme == "sms" {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }

            // 4. Handle APK download or external attachments
            if url.pathExtension.lowercased() == "apk" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.state.isLoading = true
                self.parent.state.hasError = false
            }
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.state.isLoading = false
                self.parent.state.hasError = false
                webView.scrollView.refreshControl?.endRefreshing()
            }
        }

        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.state.isLoading = false
                self.parent.state.hasError = true
                self.parent.state.errorMessage = error.localizedDescription
                webView.scrollView.refreshControl?.endRefreshing()
            }
        }

        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.state.isLoading = false
                self.parent.state.hasError = true
                self.parent.state.errorMessage = error.localizedDescription
                webView.scrollView.refreshControl?.endRefreshing()
            }
        }
    }
}

// MARK: - Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
