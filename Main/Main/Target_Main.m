//
//  Target_Main.m
//  Main
//
//  Created by wangshiyu13 on 2017/2/1.
//  Copyright © 2017年 wangshiyu13. All rights reserved.
//

#import "Target_Main.h"
#import "SXMainViewController.h"

@implementation Target_Main
- (UIViewController *)Action_aViewController:(NSDictionary *)params {
    return [UIStoryboard storyboardWithName:@"SXMainViewController" bundle:nil].instantiateInitialViewController;
}
@end
