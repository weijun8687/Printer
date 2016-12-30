//
//  UITextField+WJ.m
//  QiShou
//
//  Created by WJ on 16/8/11.
//  Copyright © 2016年 WJ. All rights reserved.
//

#import "UITextField+WJ.h"

@implementation UITextField (WJ)


- (void)setLeftImage:(UIImage *)image isClearButton:(BOOL)show{
    
    self.backgroundColor = [UIColor whiteColor];
    self.font = [UIFont systemFontOfSize:14.0];
    
    if (show) {
        self.clearButtonMode = UITextFieldViewModeAlways;
    }else{
        self.clearButtonMode = UITextFieldViewModeNever;
    }
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    iv.width = 15;
    iv.height = 15;
    [self setLeftView:iv];

    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setRightButton:(UIButton *)rightButton{
    [self setRightView:rightButton];
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.origin.x = 10;
    rect.origin.y = 19;
    rect.size.height = 15;
    rect.size.width = 15;
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.origin.x = self.frame.size.width - 30;
    rect.origin.y = 22;
    rect.size.height = 10;
    rect.size.width = 15;
    return rect;
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.origin.x = 40;
    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.origin.x = 40;
    return rect;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    CGRect rect = bounds;
    rect.origin.x = 40;
    return rect;
}


@end
