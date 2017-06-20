//
//  UIAlertAction+Hook.m
//  iOSTest
//
//  Created by 黄瑞 on 2017/6/9.
//  Copyright © 2017年 CoderHuang. All rights reserved.
//

#import "UIAlertAction+Hook.h"

@implementation UIAlertAction (Hook)

+ (void)load {
    SEL orig = @selector(actionWithTitle:style:handler:);
    SEL my = @selector(myactionWithTitle:style:handler:);
    [self exchangeorig:orig my:my];
}

+ (void)exchangeorig:(SEL)orig my:(SEL)my {
    Method origm = class_getClassMethod(self, orig);
    Method mym = class_getClassMethod(self, my);
    method_exchangeImplementations(origm, mym);
}

+ (instancetype)myactionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction * _Nonnull))handler {
    NSLog(@"%s", __func__);
    return [self myactionWithTitle:title style:style handler:handler];
}

@end
