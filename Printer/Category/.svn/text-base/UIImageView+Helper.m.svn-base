//
//  UIImageView+Helper.m
//  xc
//
//  Created by Michael on 3/14/16.
//  Copyright © 2016 bjtongan. All rights reserved.
//

#import "UIImageView+Helper.h"

@implementation UIImageView(Helper)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)cropCorner{

    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    if (w != h) {
        return;
    }
    self.layer.cornerRadius = w/2;
    self.layer.masksToBounds = YES;
}


-(void)cropCornerWithBorder:(UIColor*)color width:(CGFloat)width{

    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    if (w != h) {
        return;
    }
    self.layer.cornerRadius = w/2;
    self.layer.masksToBounds = YES;
//    self.layer.borderColor = color.CGColor;
//    self.layer.borderWidth = width;
}

- (void)cropCornerWithBorder:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}


@end
