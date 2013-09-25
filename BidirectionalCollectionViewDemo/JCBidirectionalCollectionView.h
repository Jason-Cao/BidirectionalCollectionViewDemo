//
//  JCBidirectionalCollectionView.h
//  JCCollectionViewDemo
//
//  Created by Jason CAO on 13-8-28.
//  Copyright (c) 2013年 Jason CAO. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JCBidirectionalCollectionView;
@class JCReusableView;

@protocol JCBidirectionalCollectionViewDataSource <NSObject>
@required

- (NSInteger)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSInteger)numberOfSectionsInBidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView;

- (JCReusableView *)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView backgroundViewForSection:(NSInteger)section;
//To Do
//- (JCCollectionReusableView *)collectionView:(JCCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol JCBidirectionalCollectionViewDelegate <NSObject>
@optional

- (void)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView heightOfSection:(NSInteger)section;
- (CGSize)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (UIEdgeInsets)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView minimumLineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

- (UIEdgeInsets)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView scrollContentInsetForSectionAtIndex:(NSInteger)section;

@end

@interface JCReusableView : UIView

@property (nonatomic, strong) NSString *reuseIdentifier;

- (id)initWithFrame:(CGRect)frame;

@end

@interface JCBidirectionalCollectionView : UIView

@property (nonatomic, strong) UITableView *contentView;
//@property (nonatomic, strong) UICollectionViewLayout *bidirectionalCollectionViewLayout;
@property (nonatomic, weak) id <JCBidirectionalCollectionViewDataSource> dataSource;
@property (nonatomic, weak) id <JCBidirectionalCollectionViewDelegate> delegate;

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerClass:(Class)viewClass forSectionBackgroundViewWithReuseIdentifier:(NSString *)identifier;
- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath;
//- (id)dequeueReusableSectionBackgroundViewWithReuseIdentifier:(NSString *)identifier forSection:(NSInteger)section;
//- (void)registerClass:(Class)viewClass forCellWithReuseIdentifier:(NSString *)identifier;
- (id)dequeueReusableViewWithReuseIdentifier:(NSString *)identifier;

@end
