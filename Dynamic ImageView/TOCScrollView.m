//
//  TOCScrollView.m
//  Dynamic ImageView
//
//  Created by Tobias Conradi on 11.11.13.
//  Copyright (c) 2013 Tobias Conradi. All rights reserved.
//

#import "TOCScrollView.h"

@implementation TOCScrollView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (![self.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return;
    }
    UIView *contentView = [self.delegate viewForZoomingInScrollView:self];
    
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = contentView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    contentView.frame = frameToCenter;
}

@end
