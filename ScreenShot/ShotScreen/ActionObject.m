//
//  ActionObject.m
//  ScreenShot
//
//  Created by wuxi on 2021/11/23.
//

#import "ActionObject.h"

@implementation ActionObject

- (instancetype)initWithType:(ActionType)type color:(PenColor)color scale:(double)scale penSize:(PenSize)penSize {
    if (!self) {
        self = [super init];
    }
    self.actionType = type;
    self.penColor = color;
    self.scale = scale;
    self.penSize = penSize;
    return self;
}

-(void)setParams:(PenColor)color scale:(double)scale penSize:(PenSize)penSize {
    self.penColor = color;
    self.scale = scale;
    self.penSize = penSize;
}

- (PenColor)penColor {
    if (!_penColor) {
        return 0;
    }
    return _penColor;
}

- (UIColor *)color {
    NSArray *colorArr = @[@"#FF0000",@"#FF7F00",@"#FFFF00",@"#00FF00",@"#00FFFF",@"#0000FF",@"#8B00FF",@"#000000",@"#AAAAAA"];
    return [ActionObject ColorwithHexString:colorArr[_penColor] Alpha:1];
}

+(UIColor *)getColorByEnumValue:(PenColor)color {
    NSArray *colorArr = @[@"#FF0000",@"#FF7F00",@"#FFFF00",@"#00FF00",@"#00FFFF",@"#0000FF",@"#8B00FF",@"#000000",@"#AAAAAA"];
    return [ActionObject ColorwithHexString:colorArr[color] Alpha:1];
}

+ (UIColor *)ColorwithHexString:(NSString *)color Alpha:(CGFloat)alpha {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 8 && [cString length]!=6)
        return [UIColor clearColor];

    CGFloat insideAlpha = 1.0f;
    if ([cString length]==8) {
        NSString *aString = [cString substringWithRange:NSMakeRange(0, 2)];
        unsigned int a;
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        insideAlpha = (float)a / 255.0f;
        cString =  [cString substringWithRange:NSMakeRange(2, 6)];
    }
    if (alpha>0) {
        insideAlpha = alpha;
    }

    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;

    //r
    NSString *rString = [cString substringWithRange:range];

    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:insideAlpha];
}

@end
