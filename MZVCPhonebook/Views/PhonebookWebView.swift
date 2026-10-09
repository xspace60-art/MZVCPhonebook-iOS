import SwiftUI
import WebKit

// MARK: - Phonebook Web Container View
/// Main entry container that displays http://129.225.98.64/phonebook/
/// Handles full-screen rendering, pull-to-refresh, call interception, and offline failover.
public struct PhonebookWebContainerView: View {
    @StateObject private var webState = WebViewState()
    @State private var showOfflineDirectory: Bool = false
    @State private var showFloatingControls: Bool = true
    @State private var showShareSheet: Bool = false
    
    private let phonebookURL = URL(string: "http://129.225.98.64/phonebook/")!

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main WebView
            PhonebookWebViewRepresentable(state: webState, targetURL: phonebookURL)
                .ignoresSafeArea(.container, edges: .all)

            // Top Progress Bar
            VStack(spacing: 0) {
                if webState.isLoading && webState.progress < 1.0 {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.07, green: 0.36, blue: 0.50), Color(red: 0.06, green: 0.72, blue: 0.51)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(webState.progress), height: 3.5)
                            .animation(.easeOut(duration: 0.2), value: webState.progress)
                    }
                    .frame(height: 3.5)
                }
                Spacer()
            }
            .ignoresSafeArea(.container, edges: .top)

            // Offline / Connection Error Overlay
            if webState.hasError {
                VStack(spacing: 18) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(Color(red: 0.07, green: 0.36, blue: 0.50))

                    VStack(spacing: 6) {
                        Text("Connection Offline")
                            .font(.system(size: 20, weight: .bold))

                        Text("Unable to reach the live phonebook at\nhttp://129.225.98.64/phonebook/\nPlease check your network connection.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
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
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 8)
                )
                .padding(24)
                .transition(.opacity.combined(with: .scale))
            }

            // Compact Floating Navigation Pill
            if showFloatingControls && !webState.hasError {
                HStack(spacing: 18) {
                    // Back button
                    Button(action: {
                        webState.goBack()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(webState.canGoBack ? .primary : .secondary.opacity(0.4))
                    }
                    .disabled(!webState.canGoBack)

                    // Forward button
                    Button(action: {
                        webState.goForward()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(webState.canGoForward ? .primary : .secondary.opacity(0.4))
                    }
                    .disabled(!webState.canGoForward)

                    Divider()
                        .frame(height: 18)

                    // Reload
                    Button(action: {
                        webState.reload()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    // Share
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Divider()
                        .frame(height: 18)

                    // Offline Directory Mode Switcher
                    Button(action: {
                        showOfflineDirectory = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 12))
                            Text("Saved")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(Color(red: 0.07, green: 0.36, blue: 0.50))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $showOfflineDirectory) {
            MainTabView()
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

    fileprivate var webViewReference: WKWebView? = nil

    public func reload() {
        hasError = false
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

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
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

        // Add estimatedProgress and navigation state observers
        context.coordinator.setupObservers(for: webView)

        // Load the phonebook URL
        let request = URLRequest(url: targetURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15.0)
        webView.load(request)

        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}

    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
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

        // Intercept links: tel:, whatsapp:, mailto:, sms:
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let scheme = url.scheme?.lowercased() ?? ""

            // Telephone calling interception
            if scheme == "tel" || scheme == "telprompt" {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }

            // WhatsApp link interception
            if scheme == "whatsapp" || url.host?.contains("whatsapp.com") == true || url.host?.contains("wa.me") == true {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else if let webURL = URL(string: url.absoluteString.replacingOccurrences(of: "whatsapp://send", with: "https://api.whatsapp.com/send")) {
                    UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }

            // Mail and SMS
            if scheme == "mailto" || scheme == "sms" {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                decisionHandler(.cancel)
                return
            }

            // Handle APK download or external attachments
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
