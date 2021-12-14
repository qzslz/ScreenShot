//
//  AppDelegate.m
//  ScreenShot
//
//  Created by wuxi on 2021/11/22.
//

#import "AppDelegate.h"
#import "ShotScreen/EditMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    
    if (@available(iOS 13.0,*)) {
        
    }
    else{
        self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
        self.window.rootViewController = [[EditMainViewController alloc]init];
    }
    
    return YES;
}

void UncaughtExceptionHandler(NSException *exception) {
  /**
   *  获取异常崩溃信息
   */
  NSArray *callStack = [exception callStackSymbols];
  NSString *reason = [exception reason];
  NSString *name = [exception name];
    NSLog(@"reason=%@,stack=%@",reason,callStack);
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
