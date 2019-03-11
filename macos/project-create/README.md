## 项目生成

#### 创建 TTBrowser 项目
![ttbrowser-create](./images/ttbrowser-create.png)

#### 在 TTBrowser 项目内创建Target, 名字为：TTBrowser Helper 
![ttbrowser-helper-create](./images/ttbrowser-helper-create.png)


## 创建基本代码

#### TTBrowser
删除 AppDelegate.h AppDelegate.m MainMenu.xib <br>
将 TTBrowser 配置中的 Main interface 设置为空 <br>
将 main.m 改名为 main.mm, 并用如下内容替代 <br>
```C
#import <Cocoa/Cocoa.h>

#include "include/cef_app.h"
#include "include/wrapper/cef_library_loader.h"
#include "include/views/cef_browser_view.h"

class SZApp : public CefApp {
public:
    SZApp() {}
private:
    // Include the default reference counting implementation.
    IMPLEMENT_REFCOUNTING(SZApp);
};

class SZBrowserHandler : public CefClient {
public:
    SZBrowserHandler() {}
private:
    // Include the default reference counting implementation.
    IMPLEMENT_REFCOUNTING(SZBrowserHandler);
};


@interface RootView : NSView
@end
@implementation RootView
- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    CefRefPtr<SZBrowserHandler> handler(new SZBrowserHandler());
    CefBrowserSettings browser_settings;
    CefWindowInfo info;
    
    info.SetAsChild(self,
                    self.bounds.origin.x,
                    self.bounds.origin.y,
                    self.bounds.size.width,
                    self.bounds.size.height
                    );
    
    CefBrowserHost::CreateBrowserSync(info,
                                      handler,
                                      "https://bing.com",
                                      browser_settings,
                                      nil);
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end
@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create Window
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    CGFloat winWidth = screenSize.width * 0.8;
    CGFloat winHeight = screenSize.height * 0.8;
    
    NSWindow *win = [[NSWindow alloc]
                     initWithContentRect: NSMakeRect((screenSize.width - winWidth)/2,
                                                     (screenSize.height - winHeight) /2,
                                                     winWidth,
                                                     winHeight)
                     styleMask: NSWindowStyleMaskTitled | NSWindowStyleMaskResizable
                     backing: NSBackingStoreBuffered
                     defer: true];
    [win makeKeyAndOrderFront:nil];
    
    // Add RootView
    NSView* rootView = [[RootView alloc] initWithFrame:win.contentView.bounds];
    rootView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [[win contentView] addSubview:rootView];
}
@end

// Entry Point
int main(int argc, char* argv[]) {
    @autoreleasepool {
        // Load the CEF framework library at runtime
        CefScopedLibraryLoader library_loader;
        if (!library_loader.LoadInMain())
            return 1;
        
        // Provide CEF with command-line arguments.
        CefMainArgs main_args(argc, argv);
        
        // Initialize CEF for the browser process.
        CefSettings settings;
        CefRefPtr<SZApp> app(new SZApp);
        CefInitialize(main_args, settings, app.get(), NULL);
        
        // Create the application delegate.
        AppDelegate* appDelegate = [[AppDelegate alloc] init];
        NSApplication.sharedApplication.delegate = appDelegate;
        
        // Run the CEF message loop. This will block until CefQuitMessageLoop() is called.
        CefRunMessageLoop();
        CefShutdown();
    }
    return 0;
}
```

#### TTBrowser Helper
删除 AppDelegate.h AppDelegate.m MainMenu.xib <br>
将 TTBrowser Helper 配置中的 Main interface 设置为空 <br>
将 main.m 改名为 main.mm, 并用如下内容替代 <br>
```C
#include "include/cef_app.h"
#include "include/wrapper/cef_library_loader.h"
#include "include/cef_sandbox_mac.h"

// Entry point function for sub-processes.
int main(int argc, char* argv[]) {
    // Initialize the macOS sandbox for this helper process.
    CefScopedSandboxContext sandbox_context;
    if (!sandbox_context.Initialize(argc, argv))
        return 1;
    
    // Load the CEF framework library at runtime instead of linking directly
    // as required by the macOS sandbox implementation.
    CefScopedLibraryLoader library_loader;
    if (!library_loader.LoadInHelper())
        return 1;
    
    // Provide CEF with command-line arguments.
    CefMainArgs main_args(argc, argv);
    
    // Execute the sub-process.
    return CefExecuteProcess(main_args, NULL, NULL);
}
```

## 配置项目

#### Header Search Path
配置为 $(SRCROOT)/libs/cef <br>
![header-search-path](./images/header-search-path.png)

#### Other Linker Flags
配置 -framework Cocoa $(SRCROOT)/libs/cef/$(CONFIGURATION)/libcef_dll_wrapper.a $(SRCROOT)/libs/cef/$(CONFIGURATION)/cef_sandbox.a <br>
![other-linker-flags](./images/other-linker-flags.png)

#### Other Warning Flags
Debug配置为 '-mmacosx-version-min=10.11' -Wno-narrowing <br>
Release配置为 -DNDEBUG '-mmacosx-version-min=10.11' -Wno-narrowing

![other-warning-flags](./images/other-warning-flags.png)

#### Suspicious Commas
配置为No
![suspicious-commas](./images/suspicious-commas.png)

#### Automatic Reference Counting
配置为No
![close-arc](./images/close-arc.png)

#### 取消签名
![sign-remove](./images/sign-remove.png)	配置为No

## 打包 framework 和 Helper 程序
在主项目中，Build Phase 中加入拷贝库脚本，并移动到最后面
```bash
# copy libs
Contents="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app/Contents"
rm -rf "${Contents}/Frameworks"
mkdir -p "${Contents}/Frameworks"
cp -r "${SRCROOT}/libs/cef/${CONFIGURATION}/Chromium Embedded Framework.framework" "${Contents}/Frameworks/"
cp -r "${SRCROOT}/libs/Carthage/Build/Mac/CocoaLumberjack.framework" "${Contents}/Frameworks/"
cp -r "${SRCROOT}/libs/Carthage/Build/Mac/SVGKit.framework" "${Contents}/Frameworks/"
cp -r "${BUILT_PRODUCTS_DIR}/${TARGET_NAME} Helper.app" "${Contents}/Frameworks/"
```
![run-script](./images/run-script.png)

## 让Helper程序随主程序一起编译
![helper-build](./images/helper-build.png)

## 下载库文件
进入到工作空间根目录，执行如下命令
```bash
$ curl -s https://raw.githubusercontent.com/kztool/cef-utils/master/macos/cef3626/install.sh | bash
```


