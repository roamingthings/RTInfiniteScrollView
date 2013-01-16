//
//  RTInfiniteScrollViewExampleViewController.h
//  RTInfiniteScrollViewExample
//

#import <UIKit/UIKit.h>
#import "RTInfiniteScrollView.h"

@interface RTInfiniteScrollViewExampleViewController : UIViewController <RTInfiniteScrollViewDataSource> {
    IBOutlet RTInfiniteScrollView *_scrollView;
    
    IBOutlet UIScrollView *_testScroller;
}

- (UIView *)infiniteScrollView:(RTInfiniteScrollView *)infiniteScrollView tileForIndex:(NSUInteger)index;

@end
