//
//  JCBidirectionalCollectionView.m
//  JCCollectionViewDemo
//
//  Created by Jason CAO on 13-8-28.
//  Copyright (c) 2013年 Jason CAO. All rights reserved.
//

#import "JCBidirectionalCollectionView.h"
#import "InnerShadowView.h"

@interface JCTableViewCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JCReusableView *bgView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier delegate:(id)delegate;

@end

@implementation JCTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier delegate:delegate
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UICollectionViewFlowLayout *myFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        myFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        myFlowLayout.minimumInteritemSpacing = 0;
        myFlowLayout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:myFlowLayout];
        _collectionView.dataSource = delegate;
        _collectionView.delegate = delegate;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_collectionView];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configBgView:(JCReusableView *)view
{
    if (_bgView) {
        [_bgView removeFromSuperview];
    }
    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self insertSubview:view belowSubview:_collectionView];
//    [self addSubview:view];
    [self bringSubviewToFront:_collectionView];
    self.bgView = view;
}

@end

@interface ReusableViewObject : NSObject

@property (nonatomic, assign) Class viewClass;
@property (nonatomic, strong) NSMutableArray *viewQueue;

@end

@implementation ReusableViewObject

- (id)init
{
    self = [super init];
    if (self) {
        _viewQueue = [NSMutableArray array];
    }
    return self;
}

@end

@implementation JCReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

@end

@interface JCBidirectionalCollectionView () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{    
    NSMutableDictionary *registeredCellClasses;
//    NSMutableDictionary *registeredSectionBgViewClasses;
//    NSMutableDictionary *managedSectionBackgroundViews;
//    NSMutableArray *reusableSectionBgViewQueue;
    NSMutableDictionary *managedReusableViews;
    NSMutableDictionary *managedCollectionViews;
    NSIndexPath *selectedIndexPath;
    NSMutableDictionary *savedContentOffset;
}

@end

@implementation JCBidirectionalCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UITableView alloc] init];
        _contentView.dataSource = self;
        _contentView.delegate = self;
        _contentView.frame = self.bounds;
        [self addSubview:_contentView];
        _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_contentView setFrame:(CGRect){.origin = CGPointZero, .size = frame.size}];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier
{
    if (registeredCellClasses == nil) {
        registeredCellClasses = [NSMutableDictionary dictionary];
    }
    [registeredCellClasses setValue:cellClass forKey:identifier];
}

- (void)registerClass:(Class)viewClass forSectionBackgroundViewWithReuseIdentifier:(NSString *)identifier
{
    if (managedReusableViews == nil) {
        managedReusableViews = [NSMutableDictionary dictionary];
    }
    ReusableViewObject *reusableViewObject = [[ReusableViewObject alloc] init];
    reusableViewObject.viewClass = viewClass;   
    [managedReusableViews setObject:reusableViewObject forKey:identifier];
}

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath*)indexPath
{
    UICollectionView *collectionView = [self getManagedCollectionViewForIndex:indexPath.section];
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
}

//- (id)dequeueReusableSectionBackgroundViewWithReuseIdentifier:(NSString *)identifier forSection:(NSInteger)section
//{
////    static NSString *JCSectionBackgroundView = @"JCBidirectionalCollectionViewSectionBackgroundView";
////    UICollectionView *collectionView = [self getManagedCollectionViewForIndex:section];
////    if (collectionView) {
////        return [collectionView dequeueReusableSupplementaryViewOfKind:JCSectionBackgroundView withReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
////    } else return nil;
//    if (managedSectionBackgroundViews == nil) {
//        managedSectionBackgroundViews = [NSMutableDictionary dictionary];
//        
//    }
//    UIView *reusableView = [managedSectionBackgroundViews objectForKey:[NSNumber numberWithInteger:section]];
//    if (reusableView == nil) {
//        reusableView = [self bidirectionalCollectionView:self backgroundViewForSection:section];
//        [managedSectionBackgroundViews setObject:reusableView forKey:[NSNumber numberWithInteger:section]];
//        NSLog(@"bgView:%@ for section:%d",reusableView,section);
//    }
//    
//    if (reusableSectionBgViewQueue == nil) {
//        reusableSectionBgViewQueue = [NSMutableArray array];
//    }
//    
//    return reusableView;
//}

- (void)enqueueReusableView:(JCReusableView *)view
{
    if (managedReusableViews == nil) {
        managedReusableViews = [NSMutableDictionary dictionary];
    }
    if (![view isKindOfClass:[JCReusableView class]]) {
        return;
    }
    ReusableViewObject *reuseViewObject = [managedReusableViews objectForKey:view.reuseIdentifier];
    if (reuseViewObject) {
        if ([view isKindOfClass:reuseViewObject.viewClass]) {
            [reuseViewObject.viewQueue addObject:view];
        }
    }
}

- (id)dequeueReusableViewWithReuseIdentifier:(NSString *)identifier
{
    if (managedReusableViews == nil) {
        return nil;
    }
    ReusableViewObject *reuseViewObject = [managedReusableViews objectForKey:identifier];
    if (reuseViewObject) {
        if (reuseViewObject.viewQueue.count > 0) {
            JCReusableView *reusableView = reuseViewObject.viewQueue.lastObject;
            [reuseViewObject.viewQueue removeLastObject];
            return reusableView;
        } else {
            JCReusableView *newView = [[reuseViewObject.viewClass alloc] initWithFrame:CGRectZero];
            newView.reuseIdentifier = identifier;
//            NSLog(@"new JCReusableView: %@",newView);
            return newView;
        }
    } else return nil;
}

- (void)collectionView:(UICollectionView *)collectionView registerCellClasses:(NSDictionary *)classes
{
    for (NSString *identifier in [classes allKeys]) {
        [collectionView registerClass:[classes valueForKey:identifier] forCellWithReuseIdentifier:identifier];
    }
}

#pragma mark - JCBidirectionalCollectionView DataSource

- (NSInteger)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(bidirectionalCollectionView:numberOfItemsInSection:)]) {
        
        return [self.dataSource bidirectionalCollectionView:collectionView numberOfItemsInSection:section];
    } else return 0;
}

- (UICollectionViewCell *)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(bidirectionalCollectionView:cellForItemAtIndexPath:)]) {
        return [self.dataSource bidirectionalCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInBidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView
{
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInBidirectionalCollectionView:)]) {
        return [self.dataSource numberOfSectionsInBidirectionalCollectionView:collectionView];
    } else return 0;
}

- (JCReusableView *)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView backgroundViewForSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(bidirectionalCollectionView:backgroundViewForSection:)]) {
        return [self.dataSource bidirectionalCollectionView:collectionView backgroundViewForSection:section];
    } else return nil;
}

#pragma mark - JCBidirectionalCollectionView Delegate

- (void)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate bidirectionalCollectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

- (void)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:didDeselectItemAtIndexPath:)]) {
        [self.delegate bidirectionalCollectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}

- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView heightOfSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:heightOfSection:)]) {
        return [self.delegate bidirectionalCollectionView:collectionView heightOfSection:section];
    } else return 44.0f;
}

- (CGSize)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:sizeForItemAtIndexPath:)]) {
        return [self.delegate bidirectionalCollectionView:collectionView sizeForItemAtIndexPath:indexPath];
    } else return CGSizeZero;
}

- (UIEdgeInsets)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView insetForSectionAtIndex:(NSInteger)section;
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:insetForSectionAtIndex:)]) {
        return [self.delegate bidirectionalCollectionView:collectionView insetForSectionAtIndex:section];
    } else return UIEdgeInsetsZero;
}

- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView minimumLineSpacingForSectionAtIndex:(NSInteger)section;
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:minimumLineSpacingForSectionAtIndex:)]) {
        return [self.delegate bidirectionalCollectionView:collectionView minimumLineSpacingForSectionAtIndex:section];
    } else return 0;
}

- (CGFloat)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:minimumInteritemSpacingForSectionAtIndex:)]) {
        return [self.delegate bidirectionalCollectionView:collectionView minimumInteritemSpacingForSectionAtIndex:section];
    } else return 0;
}

- (UIEdgeInsets)bidirectionalCollectionView:(JCBidirectionalCollectionView *)collectionView scrollContentInsetForSectionAtIndex:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(bidirectionalCollectionView:scrollContentInsetForSectionAtIndex:)]) {
        return [self.delegate bidirectionalCollectionView:collectionView scrollContentInsetForSectionAtIndex:section];
    } else return UIEdgeInsetsZero;
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    JCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[JCTableViewCell alloc] initWithReuseIdentifier:CellIdentifier delegate:self];
        [self collectionView:cell.collectionView registerCellClasses:registeredCellClasses];
    }
    cell.collectionView.frame = UIEdgeInsetsInsetRect(cell.bounds, [self bidirectionalCollectionView:self scrollContentInsetForSectionAtIndex:indexPath.section]);
    [self manageCollectionView:cell.collectionView forIndex:indexPath.section];
    [cell.collectionView reloadData];
    [self restoreStateToCollectionView:cell.collectionView forKey:[NSNumber numberWithInteger:indexPath.section]];
    
    JCReusableView *reusableBgView = [self bidirectionalCollectionView:self backgroundViewForSection:indexPath.section];
    [cell configBgView:reusableBgView];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSectionsInBidirectionalCollectionView:self];
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self bidirectionalCollectionView:self heightOfSection:indexPath.section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
//    NSLog(@"did end display cell for index path:%@",indexPath);
    if ([cell isKindOfClass:[JCTableViewCell class]] && [[(JCTableViewCell *)cell bgView] isKindOfClass:[JCReusableView class]]) {
        [self enqueueReusableView:[(JCTableViewCell *)cell bgView]];
    }
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self bidirectionalCollectionView:self numberOfItemsInSection:[self getManagedIndexOfCollectionView:collectionView]];
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self bidirectionalCollectionView:self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:[self getManagedIndexOfCollectionView:collectionView]]];
}

#pragma mark - UICollectionView Delegate FlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *correctedIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:[self getManagedIndexOfCollectionView:collectionView]];
    [self bidirectionalCollectionView:self didSelectItemAtIndexPath:correctedIndexPath];
    
    if (selectedIndexPath.section == correctedIndexPath.section) {
        
        if (selectedIndexPath.item == correctedIndexPath.item) {
            return;
        } else {
            selectedIndexPath = correctedIndexPath;
        }
    } else {
        UICollectionView *selectedCollectionView = [self getManagedCollectionViewForIndex:selectedIndexPath.section];
        [selectedCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndexPath.item inSection:0] animated:NO];
        [self bidirectionalCollectionView:self didDeselectItemAtIndexPath:selectedIndexPath];
        selectedIndexPath = correctedIndexPath;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self bidirectionalCollectionView:self didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:[self getManagedIndexOfCollectionView:collectionView]]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self bidirectionalCollectionView:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:[self getManagedIndexOfCollectionView:collectionView]]];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return [self bidirectionalCollectionView:self insetForSectionAtIndex:[self getManagedIndexOfCollectionView:collectionView]];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self bidirectionalCollectionView:self minimumLineSpacingForSectionAtIndex:[self getManagedIndexOfCollectionView:collectionView]];
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [self bidirectionalCollectionView:self minimumInteritemSpacingForSectionAtIndex:[self getManagedIndexOfCollectionView:collectionView]];
}

#pragma mark - CollectionViews Management

- (void)manageCollectionView:(UICollectionView *)collectionView forIndex:(NSInteger)index
{
    if (managedCollectionViews == nil) {
        managedCollectionViews = [NSMutableDictionary dictionary];
    }
    if (collectionView == nil) {
        return;
    }
    if (collectionView == [managedCollectionViews objectForKey:[NSNumber numberWithInteger:index]]) {
        return;
    }
    NSArray *keyArray = [managedCollectionViews allKeysForObject:collectionView];
    if ([keyArray count]) {
        [managedCollectionViews removeObjectsForKeys:keyArray];
        //save state of collectionViews to be reused
//        NSLog(@"key array count: %d",keyArray.count);  
        for (id key in keyArray) {
            [self saveStateOfCollectionView:collectionView forKey:key];
        }
    }
    [managedCollectionViews setObject:collectionView forKey:[NSNumber numberWithInteger:index]];
    
//    NSLog(@"managedCollectionViews: %@",managedCollectionViews);
}

- (NSInteger)getManagedIndexOfCollectionView:(UICollectionView *)collectionView
{
    if (managedCollectionViews == nil) {
        return NSNotFound;
    }

    NSArray *keyArray = [managedCollectionViews allKeysForObject:collectionView];
    if (keyArray.count) {
        if (keyArray.count > 1) {
            NSLog(@"Mutiple keys for same collectionView.");
            return NSNotFound;
        } else {
            NSNumber *key = [keyArray objectAtIndex:0];
            return key.integerValue;
        }
        
    } else return NSNotFound;
}

- (UICollectionView *)getManagedCollectionViewForIndex:(NSInteger)index
{
    if (managedCollectionViews == nil) {
        return nil;
    }
    return [managedCollectionViews objectForKey:[NSNumber numberWithInteger:index]];
}

- (void)saveStateOfCollectionView:(UICollectionView *)collectionView forKey:(id)key
{
    if (savedContentOffset == nil) {
        savedContentOffset = [NSMutableDictionary dictionary];
    }
//    NSLog(@"saveStateOfCollectionViewOffset:%@ forKey:%@",NSStringFromCGPoint(collectionView.contentOffset),key);
    [savedContentOffset setObject:[NSValue valueWithCGPoint:collectionView.contentOffset] forKey:key];
}

- (void)restoreStateToCollectionView:(UICollectionView *)collectionView forKey:(id)key
{
    NSValue *offsetValue = [savedContentOffset objectForKey:key];
    if (offsetValue) {
//        NSLog(@"restoreStateToCollectionViewOffset:%@ forKey:%@",NSStringFromCGPoint([offsetValue CGPointValue]),key);
        collectionView.contentOffset = [offsetValue CGPointValue];
    } else collectionView.contentOffset = CGPointZero;
}

@end
