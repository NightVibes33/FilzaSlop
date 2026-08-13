@import UIKit;

#import <objc/message.h>
#import <objc/runtime.h>

#import "FilzaDiagnostics.h"
#import "FilzaMondBridge.h"

static __strong id gMondAccessBootstrap = nil;

static UIViewController *FMActiveController(void)
{
    UIWindow *window = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (![scene isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
            if (candidate.isKeyWindow) { window = candidate; break; }
            if (!window && !candidate.hidden) window = candidate;
        }
        if (window.isKeyWindow) break;
    }
    if (!window) {
        for (UIWindow *candidate in UIApplication.sharedApplication.windows) {
            if (candidate.isKeyWindow) { window = candidate; break; }
            if (!window && !candidate.hidden) window = candidate;
        }
    }

    UIViewController *controller = window.rootViewController;
    while (controller) {
        UIViewController *next = controller.presentedViewController;
        if (!next && [controller isKindOfClass:UINavigationController.class])
            next = ((UINavigationController *)controller).visibleViewController;
        if (!next && [controller isKindOfClass:UITabBarController.class])
            next = ((UITabBarController *)controller).selectedViewController;
        if (!next && [controller isKindOfClass:UISplitViewController.class])
            next = ((UISplitViewController *)controller).viewControllers.lastObject;
        if (!next || next == controller) break;
        controller = next;
    }
    return controller;
}

static void FMPresentHost(UIViewController *source, NSString *path)
{
    Class factory = NSClassFromString(@"MondGestaltHostFactory");
    SEL selector = NSSelectorFromString(@"makeViewControllerWithPath:");
    if (!factory || ![factory respondsToSelector:selector]) {
        FilzaDiagnosticsAppend(@"Mond", @"Swift mond host factory unavailable");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"mond unavailable"
            message:@"The embedded mond SwiftUI host was not present in this build."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [source presentViewController:alert animated:YES completion:nil];
        return;
    }

    UIViewController *controller = ((id (*)(id, SEL, id))objc_msgSend)(factory, selector, path);
    if (![controller isKindOfClass:UIViewController.class]) {
        FilzaDiagnosticsAppend(@"Mond", @"Swift mond host factory returned no controller");
        return;
    }

    UINavigationController *navigation = source.navigationController;
    if (navigation && !source.presentedViewController) {
        [navigation pushViewController:controller animated:YES];
    } else {
        UINavigationController *wrapper = [[UINavigationController alloc] initWithRootViewController:controller];
        wrapper.modalPresentationStyle = UIModalPresentationFullScreen;
        [source presentViewController:wrapper animated:YES completion:nil];
    }
    FilzaDiagnosticsAppend(@"Mond", [NSString stringWithFormat:@"presented embedded mond using %@", path]);
}

static void FMPollResolvedPath(UIViewController *source, NSUInteger attempts)
{
    id bootstrap = gMondAccessBootstrap;
    NSString *path = nil;
    @try {
        id value = [bootstrap valueForKey:@"plistPath"];
        if ([value isKindOfClass:NSString.class]) path = value;
    } @catch (__unused NSException *exception) {}

    if (path.length) {
        gMondAccessBootstrap = nil;
        FMPresentHost(source, path);
        return;
    }

    if (attempts == 0) {
        gMondAccessBootstrap = nil;
        FilzaDiagnosticsAppend(@"Mond", @"existing Gestalt access controller did not resolve a plist path");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MobileGestalt unavailable"
            message:@"The existing Filza Gestalt access path did not resolve a readable MobileGestalt plist. No second access implementation was attempted."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [source presentViewController:alert animated:YES completion:nil];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC),
                   dispatch_get_main_queue(), ^{ FMPollResolvedPath(source, attempts - 1); });
}

void FilzaMondPresentFromController(UIViewController *source)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *presenter = source ?: FMActiveController();
        if (!presenter) return;

        Class accessClass = NSClassFromString(@"GestaltManagerController");
        if (!accessClass || ![accessClass isSubclassOfClass:UIViewController.class]) {
            FilzaDiagnosticsAppend(@"Mond", @"GestaltManagerController access bootstrap unavailable");
            return;
        }

        UIViewController *bootstrap = [accessClass new];
        gMondAccessBootstrap = bootstrap;
        FilzaDiagnosticsAppend(@"Mond", @"bootstrapping existing verified Gestalt access path");
        (void)bootstrap.view;
        FMPollResolvedPath(presenter, 60);
    });
}

void FilzaMondPresent(void)
{
    FilzaMondPresentFromController(FMActiveController());
}
