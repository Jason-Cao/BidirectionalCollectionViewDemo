//
//  InnerShadowView.m
//  TeleMobile
//
//  Created by Jason CAO on 13-7-17.
//  Copyright (c) 2013年 United-Imaging. All rights reserved.
//

#import "InnerShadowView.h"

@implementation InnerShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGRect rects[] = {rect, CGRectInset(rect, -3, -3)};
    CGContextAddRects(context, rects, 2);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 4.5f, [UIColor colorWithWhite:0 alpha:0.75f].CGColor);
    CGContextEOFillPath(context);
    
    //get shape by adding path
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, rect);
//    CGPathAddRect(path, NULL, CGRectInset(rect, -3, -3));
//    CGContextAddPath(context, path);
//    
//    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
//    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 4.5f, [UIColor colorWithWhite:0 alpha:0.75f].CGColor);
//    CGContextEOFillPath(context);
//    CGPathRelease(path);
}

@end
