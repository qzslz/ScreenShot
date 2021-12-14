//
//  BaseTypes.h
//  ScreenShot
//
//  Created by wuxi on 2021/11/23.
//

#ifndef BaseTypes_h
#define BaseTypes_h

typedef enum : NSUInteger {
    BottomItemTypePen = 0,
    BottomItemTypeColor,
    BottomItemTypeMore,
} BottomItemType;

typedef enum : NSUInteger {
    PenSizeSmall = 0,
    PenSizeMiddle,
    PenSizeLarge,
} PenSize;

typedef enum : NSUInteger {
    ActionTypeRectangle = 0,
    ActionTypeCircle,
    ActionTypeTxt,
    ActionTypePoint
} ActionType;

typedef enum : NSUInteger {
    PenColorRed = 0,
    PenColorOrange,
    PenColorYellow,
    PenColorGreen,
    PenColorIndigo,
    PenColorBlue,
    PenColorPerple,
    PenColorBlack,
    PenColorGray,
} PenColor;

#endif /* BaseTypes_h */
