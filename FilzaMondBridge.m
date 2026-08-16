@import UIKit;

#import <dlfcn.h>
#import <objc/message.h>

#import "FilzaDiagnostics.h"
#import "FilzaMondBridge.h"

static void *gMond2Handle = NULL;

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

static void FMShowUnavailable(UIViewController *source, NSString *message)
{
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"mond unavailable"
        message:message
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault handler:nil]];
    [source presentViewController:alert animated:YES completion:nil];
}

static BOOL FMLoadMond2(void)
{
    if (gMond2Handle) return YES;

    NSString *frameworks = NSBundle.mainBundle.privateFrameworksPath;
    NSString *path = [frameworks stringByAppendingPathComponent:@"Mond2Embedded.dylib"];
    gMond2Handle = dlopen(path.fileSystemRepresentation, RTLD_NOW | RTLD_LOCAL);
    if (!gMond2Handle) {
        const char *error = dlerror();
        FilzaDiagnosticsAppend(@"mond", [NSString stringWithFormat:
            @"failed to load exact Mond 2.1 module: %s",
            error ?: "unknown dlopen error"]);
        return NO;
    }

    FilzaDiagnosticsAppend(@"mond",
        @"loaded exact upstream Mond 2.1 module commit=500d76082f0ca021ddd591c05d129ebbc26c20df");
    return YES;
}

static UIViewController *FMCreateHost(void)
{
    if (!FMLoadMond2()) return nil;

    Class factory = NSClassFromString(@"Mond2EmbeddedHostFactory");
    SEL selector = NSSelectorFromString(@"makeViewController");
    if (!factory || ![factory respondsToSelector:selector]) {
        FilzaDiagnosticsAppend(@"mond", @"exact Mond 2.1 host factory unavailable");
        return nil;
    }

    @try {
        UIViewController *controller =
            ((UIViewController *(*)(id, SEL))objc_msgSend)(factory, selector);
        if (![controller isKindOfClass:UIViewController.class]) {
            FilzaDiagnosticsAppend(@"mond", @"exact Mond 2.1 host returned no controller");
            return nil;
        }
        return controller;
    } @catch (NSException *exception) {
        FilzaDiagnosticsAppend(@"mond", [NSString stringWithFormat:
            @"exact Mond 2.1 host exception: %@",
            exception.reason ?: exception.name]);
        return nil;
    }
}

static BOOL FMPresentHost(UIViewController *source)
{
    UIViewController *controller = FMCreateHost();
    if (!controller) {
        FMShowUnavailable(source, @"The exact upstream Mond 2.1 interface could not be loaded.");
        return NO;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *target = source;
        while (target.presentedViewController)
            target = target.presentedViewController;
        [target presentViewController:controller animated:YES completion:^{
            FilzaDiagnosticsAppend(@"mond", @"presented exact upstream Mond 2.1 root");
        }];
    });
    return YES;
}

void FilzaMondPresentFromController(UIViewController *source)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *presenter = source ?: FMActiveController();
        if (!presenter) {
            FilzaDiagnosticsAppend(@"mond", @"no presenter available");
            return;
        }
        FMPresentHost(presenter);
    });
}

void FilzaMondPresent(void)
{
    FilzaMondPresentFromController(FMActiveController());
}

__attribute__((constructor)) static void FilzaMondInstall(void)
{
    FilzaDiagnosticsAppend(@"mond",
        @"exact upstream Mond 2.1 route installed commit=500d76082f0ca021ddd591c05d129ebbc26c20df; Filza app version remains independently anchored");
}
