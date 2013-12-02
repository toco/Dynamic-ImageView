//
//  UIView+TOC.h
//  Dynamic ImageView
//
//  Created by Tobias Conradi on 24.11.13.
//  Copyright (c) 2013 Tobias Conradi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (TOC)
- (UIOffset)toc_centerOffsetForPoint:(CGPoint)point;

- (CGVector)toc_forceFromVelocity:(CGPoint)velocity;
- (CGVector)toc_forceFromVelocity:(CGPoint)velocity withDensity:(CGFloat)density;
@end
