//
//  UIView+TOC.m
//  Dynamic ImageView
//
//  Created by Tobias Conradi on 24.11.13.
//  Copyright (c) 2013 Tobias Conradi. All rights reserved.
//

#import "UIView+TOC.h"

@implementation UIView (TOC)
- (UIOffset)toc_centerOffsetForPoint:(CGPoint)point {
    CGRect bounds = self.bounds;
    return UIOffsetMake(point.x-CGRectGetMidX(bounds), point.y-CGRectGetMidY(bounds));
}

- (CGVector)toc_forceFromVelocity:(CGPoint)velocity {
    return [self toc_forceFromVelocity:velocity withDensity:1.0];
}
- (CGVector)toc_forceFromVelocity:(CGPoint)velocity withDensity:(CGFloat)density{
    CGRect bounds = self.bounds;
    CGFloat area = CGRectGetWidth(bounds)*CGRectGetHeight(bounds);
    const CGFloat UIKitNewtonScaling = 1000000.0;
    CGFloat scaling = density*area/UIKitNewtonScaling;
    
    return CGVectorMake(velocity.x*scaling, velocity.y*scaling);
}
@end
