//
//  ViewController.m
//  BidirectionalCollectionViewDemo
//
//  Created by Jason CAO on 13-9-25.
//  Copyright (c) 2013年 Jason CAO. All rights reserved.
//

#import "ViewController.h"
#import "JCBidirectionalCollectionView.h"
#import "CollectionViewCellBox.h"
#import "InnerShadowView.h"

@interface CustomCollectionViewCell : UICollectionViewCell

@end

@implementation CustomCollectionViewCell {
    CollectionViewCellBox *selectorBox;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tree.jpg"]];
        imageView.frame = CGRectInset(self.contentView.bounds, 3, 3);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:imageView];
        selectorBox = [[CollectionViewCellBox alloc] initWithFrame:self.contentView.bounds];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        
        selectorBox.frame = self.contentView.bounds;
        [self.contentView addSubview:selectorBox];
    } else {
        
        [selectorBox removeFromSuperview];
    }
}

@end

@interface CustomBackgroundView : JCReusableView {
    InnerShadowView *shadowView;
}

@end

@implementation CustomBackgroundView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    shadowView.frame = CGRectInset(self.bounds, 10, 10);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        shadowView = [[InnerShadowView alloc] initWithFrame:CGRectZero];
        [self addSubview:shadowView];
    }
    return self;
}

@end

@interface ViewController () <JCBidirectionalCollectionViewDataSource,JCBidirectionalCollectionViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    JCBidirectionalCollectionView *testView = [[JCBidirectionalCollectionView alloc] initWithFrame:self.view.bounds];
    testView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    testView.dataSource = self;
    testView.delegate = self;
    [testView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    [testView registerClass:[CustomBackgroundView class] forSectionBackgroundViewWithReuseIdentifier:@"Cell"];
    [self.view addSubview:testView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - JCBidirectionalCollectionView DataSource

- (NSInteger)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (UICollectionViewCell *)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInBidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView
{
    return 25;
}

- (JCReusableView *)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView backgroundViewForSection:(NSInteger)section
{
    CustomBackgroundView *view = [collectionView dequeueReusableViewWithReuseIdentifier:@"Cell"];
    return view;
}

#pragma mark - JCBidirectionalCollectionView Delegate

- (void)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select item at index path: %@",indexPath);
}

- (void)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did deselect item at index path: %@",indexPath);
}

- (CGSize)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 || indexPath.section == 6) {
        return CGSizeMake(33, 33);
    } else if (indexPath.section == 5) {
        if (indexPath.item == 2) {
            return CGSizeMake(44, 44);
        } else return CGSizeMake(55, 55);
    } else return CGSizeMake(55, 55);
}

- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView heightOfSection:(NSInteger)section
{
    return 90;
}

- (UIEdgeInsets)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 6) {
        return 20;
    } else return 2;
}

- (UIEdgeInsets)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView scrollContentInsetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(11, 11, 11, 11);
}

@end
