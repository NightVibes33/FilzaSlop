import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import ObjectiveC.runtime

// Integration boundary only. The Mond 2.1 source tree is compiled unchanged in
// this same module. This host reproduces the standalone App lifecycle that
// cannot become UIApplication's @main when Mond is embedded inside Filza.
private enum Mond2EmbeddedRuntime {
    private static var configured = false

    @MainActor
    static func configureOnce() {
        guard !configured else { return }
        configured = true

        if !is_debugged() {
            setvbuf(stdout, nil, _IONBF, 0)
            dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        }

        // Exact Mond 2.1 App initializer default.
        UserDefaults.standard.register(defaults: ["method": "bad_query"])
        if UserDefaults.standard.bool(forKey: "ka_on") {
            keep_alive()
        }

        let fixed = class_getInstanceMethod(
            UIDocumentPickerViewController.self,
            #selector(UIDocumentPickerViewController.fix_init(forOpeningContentTypes:asCopy:))
        )
        let original = class_getInstanceMethod(
            UIDocumentPickerViewController.self,
            #selector(UIDocumentPickerViewController.init(forOpeningContentTypes:asCopy:))
        )
        if let fixed, let original {
            method_exchangeImplementations(original, fixed)
        }

        NSLog("[Filza/Mond] exact upstream mond 2.1 runtime configured commit=500d76082f0ca021ddd591c05d129ebbc26c20df")
    }
}

private struct Mond2EmbeddedRoot: View {
    // Exact Mond 2.1 lifecycle uses the shared AppState singleton.
    @StateObject private var state = AppState.shared

    var body: some View {
        ContentView()
            .environmentObject(state)
            .onOpenURL { url in
                guard is_pb_archive(url) else {
                    print("(mond) ignoring unsupported URL: \(url.lastPathComponent)")
                    return
                }

                state.append_poster_file(url)
            }
            .onAppear {
                if !is_supported() {
                    Alertinator.shared.alert(
                        title: "Not supported!",
                        body: "Your iOS version may not be supported by mond.\nMond only supports iOS 27.0 developer beta 1 - 4."
                    )
                }

                grant_all(state: state)
            }
            .overlay {
                if state.show_respring {
                    RespringView()
                        .brightness(-1.0)
                        .ignoresSafeArea()
                        .onAppear {
                            print("(respring) respringing now...")
                        }
                }
            }
    }
}

@MainActor
@objc(Mond2EmbeddedHostFactory)
public final class Mond2EmbeddedHostFactory: NSObject {
    @objc public static func makeViewController() -> UIViewController {
        Mond2EmbeddedRuntime.configureOnce()
        let controller = UIHostingController(rootView: Mond2EmbeddedRoot())

        // Filza owns UIApplication, so Mond must be presented modally. The host
        // adds no Mond controls and does not modify any upstream Mond source.
        controller.modalPresentationStyle = .pageSheet
        return controller
    }
}
