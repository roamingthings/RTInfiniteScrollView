//
//  RTInfiniteScrollView.m
//  RTInfiniteScrollView
//
//  Copyright (C) 2013, Alexander Sparkowsky
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "RTInfiniteScrollView.h"

@interface RTInfiniteScrollView () {
    NSMutableArray *visibleTiles;
    UIView         *tileContainerView;
    
    NSInteger _nextLeftBoundIndex;
    NSInteger _nextRightBoundIndex;
}

- (void)tileFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX;

@end

@implementation RTInfiniteScrollView

//
// Perform base initialization of this component
//
- (void)baseInitializer {
    // Make sure the content size is large enough for the scrollview to scroll
    self.contentSize = CGSizeMake(3*self.frame.size.width, self.frame.size.height);

    // Hide horizontal scroll indicator so recentering is not visible
    self.showsHorizontalScrollIndicator = NO;

    // Initialize storage for the tiles that are currently visible
    visibleTiles = [[NSMutableArray alloc] init];
    
    // Init a subview to hold the tiles currently visible in the scroll view
    tileContainerView = [[UIView alloc] init];
    tileContainerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    tileContainerView.userInteractionEnabled = NO;
    [self addSubview:tileContainerView];
    
    // Initialize index for next left and next right tiles added to the scroll view.
    // Note that the right bound value will appear as first/initial value on the left edge of the scroll view.
    _nextLeftBoundIndex = -1;
    _nextRightBoundIndex = 0;
}

#pragma mark -- Designated initializer

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self baseInitializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self baseInitializer];
    }
    return self;
}

#pragma mark -
#pragma mark Layout

//
// Recenter the content of the scrollview if neccessary to create the impression of an endless content.
//
- (void)recenterIfNecessary {
    // Calculate how far the center of the content is away from the center of the scroll view
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);

    // Recenter content of the scroll view when it's more than one forth away from the center
    if (distanceFromCenter > (contentWidth / 4.0)) {
        // Move the content back to the center
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // Move every tile back the same amount as the content so it appears to be staying still
        for (UIView *tileView in visibleTiles) {
            CGPoint center = [tileContainerView convertPoint:tileView.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            tileView.center = [self convertPoint:center toView:tileContainerView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Recenter the content if neccessary
    [self recenterIfNecessary];
 
    // Create tiles to fill up the visible bounds
    CGRect visibleBounds = [self convertRect:[self bounds] toView:tileContainerView];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    
    // Handle visible tiles
    [self tileFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

#pragma mark -
#pragma mark Tiling

//
// Create a new tile by asking the data source for it.
//
- (UIView *)insertTileAtIndex:(NSInteger)index {
    // Get a new tile from the data source
    UIView *tileView = [_dataSource infiniteScrollView:self tileForIndex:index];

    // Add new tile to the container view
    [tileContainerView addSubview:tileView];
    
    return tileView;
}

//
// Add a new tile to the right of the current content.
//
// Returns the new right edge of the content
//
- (CGFloat)placeNewTileOnRight:(CGFloat)rightEdge atIndex:(NSInteger)index {
    // Create a new tile
    UIView *tileView = [self insertTileAtIndex:index];
    // Add to the end of the cache of currently visible tiles
    [visibleTiles addObject:tileView];
    
    // Move the new tile to the right position inside the content
    CGRect frame = [tileView frame];
    frame.origin.x = rightEdge;
    frame.origin.y = [tileContainerView bounds].size.height - frame.size.height;
    [tileView setFrame:frame];
        
    return CGRectGetMaxX(frame);
}

//
// Add a new tile to the left of the current content.
//
// Returns the new left edge of the content
//
- (CGFloat)placeNewTileOnLeft:(CGFloat)leftEdge atIndex:(NSInteger)index {
    // Create a new tile
    UIView *tileView = [self insertTileAtIndex:index];
    // Add to the beginning of the cache of currently visible tiles
    [visibleTiles insertObject:tileView atIndex:0];
    
    // Move the new tile to the right position inside the content
    CGRect frame = [tileView frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [tileContainerView bounds].size.height - frame.size.height;
    [tileView setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (void)tileFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    // Add at least one tile at the left edge of the content
    if ([visibleTiles count] == 0) {
        [self placeNewTileOnRight:minimumVisibleX atIndex:_nextRightBoundIndex++];
    }
    
    // If the right edge is inside the visible area add another tile as rightmost component
    UIView *lastTile = [visibleTiles lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastTile frame]);
    while (rightEdge < maximumVisibleX) {
        // Place new tile on the right and adjust index for the next tile added to the right
        rightEdge = [self placeNewTileOnRight:rightEdge atIndex:_nextRightBoundIndex++];
    }
    
    // If the left edge is inside the visible area add another tile as leftmost component
    UIView *firstTile = [visibleTiles objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX([firstTile frame]);
    while (leftEdge > minimumVisibleX) {
        // Place new tile on the left and adjust index for the next tile added to the left
        leftEdge = [self placeNewTileOnLeft:leftEdge atIndex:_nextLeftBoundIndex--];
    }
    
    // Remove all tiles that are no longer visible on the right edge
    lastTile = [visibleTiles lastObject];
    while ([lastTile frame].origin.x > maximumVisibleX) {
        [lastTile removeFromSuperview];
        [visibleTiles removeLastObject];
        lastTile = [visibleTiles lastObject];

        // Adjust index of next tile to be added to the right
        _nextRightBoundIndex--;
    }
    
    // Remove all tiles that are no longer visible on the left edge
    firstTile = [visibleTiles objectAtIndex:0];
    while (CGRectGetMaxX([firstTile frame]) < minimumVisibleX) {
        [firstTile removeFromSuperview];
        [visibleTiles removeObjectAtIndex:0];
        firstTile = [visibleTiles objectAtIndex:0];
        
        // Adjust index of next tile to be added on the left
        _nextLeftBoundIndex++;
    }
}

@end
