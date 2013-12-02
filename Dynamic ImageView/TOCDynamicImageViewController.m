//
//  TOCDynamicImageViewController.m
//  Dynamic ImageView
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Tobias Conradi on 10.11.13.
//  Copyright (c) 2013 Tobias Conradi. All rights reserved.
//

#import "TOCDynamicImageViewController.h"
#import "UIView+TOC.h"
#import "tgmath.h"

@interface TOCDynamicImageViewController () <UIScrollViewDelegate, UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIImageView* imageView;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;
@end

@implementation TOCDynamicImageViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    if (self.triggerVelocity == 0.0) {
        self.triggerVelocity = 500.0;
    }
    self.imageView.image = self.image;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.scrollView]
                                                                    mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior = pushBehavior;
    
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.scrollView]];
    collision.collisionDelegate = self;
    self.collisionBehavior = collision;
    [self.animator addBehavior:collision];
    
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.scrollView
                                                    snapToPoint:self.view.center];
    snap.damping = 0.5;
    self.snapBehavior = snap;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageView sizeToFit];
    self.scrollView.contentSize = self.imageView.image.size;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollView.frame = self.view.bounds;

    CGRect referenceBounds = self.animator.referenceView.bounds;
    CGFloat inset = -hypot(CGRectGetWidth(referenceBounds), CGRectGetHeight(referenceBounds));
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:edgeInsets];
}

#pragma mark - UICollisionBehaviorDelegate
- (void) collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    [self.animator removeAllBehaviors];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - gesture handling

- (void)handleGestureBegin:(UIPanGestureRecognizer*)gestureRecognizer {
    CGPoint anchorPoint = [gestureRecognizer locationInView:self.view];
    CGPoint pointInScrollView = [gestureRecognizer locationInView:self.scrollView];
    UIOffset offset = [self.scrollView toc_centerOffsetForPoint:pointInScrollView];
    UIAttachmentBehavior* attachment = [[UIAttachmentBehavior alloc] initWithItem:self.scrollView
                                                                 offsetFromCenter:offset
                                                                 attachedToAnchor:anchorPoint];
    self.attachmentBehavior = attachment;
    [self.animator addBehavior:attachment];
    
    [self.animator removeBehavior:self.snapBehavior];
}
- (void)handleGestureMoved:(UIPanGestureRecognizer*)gestureRecognizer {
    CGPoint anchorPoint = [gestureRecognizer locationInView:self.view];
    self.attachmentBehavior.anchorPoint = anchorPoint;
}

- (void)handleGestureEnd:(UIPanGestureRecognizer*)gestureRecognizer {
    [self.animator removeBehavior:self.attachmentBehavior];
    
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    CGFloat velocityMagnitude = hypot(velocity.x, velocity.y);
    
    if (velocityMagnitude<self.triggerVelocity) {
        [self.animator addBehavior:self.snapBehavior];
    } else {
        
        CGPoint touchLocation = [gestureRecognizer locationInView:self.scrollView];
        UIOffset offset = [self.scrollView toc_centerOffsetForPoint:touchLocation];
        
        UIPushBehavior *pushBehavior = self.pushBehavior;
        [pushBehavior setTargetOffsetFromCenter:offset
                                        forItem:self.scrollView];
        pushBehavior.pushDirection = [self.scrollView toc_forceFromVelocity:velocity];
        pushBehavior.active = YES;
        [self.animator addBehavior:self.pushBehavior];
    }

}

-(IBAction)handlePanGesture:(UIPanGestureRecognizer*)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self handleGestureBegin:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self handleGestureMoved:gestureRecognizer];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self handleGestureEnd:gestureRecognizer];
            break;
        default:
            break;
    }
}

#pragma mark - Properties {
- (void)setImage:(UIImage *)image {
    _image = image;
    if (self.isViewLoaded) {
        self.imageView.image = image;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
