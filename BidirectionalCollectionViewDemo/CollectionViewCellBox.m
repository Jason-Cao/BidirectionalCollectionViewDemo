//
//  CollectionViewCellBox.m
//  TeleMobile
//
//  Created by Jason CAO on 13-6-5.
//  Copyright (c) 2013年 United-Imaging. All rights reserved.
//

#import "CollectionViewCellBox.h"

@implementation CollectionViewCellBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0, 129.0/255.0, 115.0/255.0, 1.0);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddRect(context, CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1, rect.size.height - 1)) ;
    CGContextStrokePath(context);
}
@end
