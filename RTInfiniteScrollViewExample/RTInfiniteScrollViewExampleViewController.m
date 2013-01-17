//
//  RTInfiniteScrollViewExampleViewController.m
//  RTInfiniteScrollViewExample
//

#import "RTInfiniteScrollViewExampleViewController.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "RTInfiniteScrollView.h"

@implementation RTInfiniteScrollViewExampleViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add some fancy shadows to the IB created scrollview
    _scrollView.layer.masksToBounds = NO;
    _scrollView.layer.shadowOffset = CGSizeMake(-2, 5);
    _scrollView.layer.shadowRadius = 5;
    _scrollView.layer.shadowOpacity = 0.5;
    
    // Add another RTInfiniteScrollView programmatically
    RTInfiniteScrollView *scrollViewProgrammatically = [[RTInfiniteScrollView alloc] initWithFrame:CGRectMake(0, 180, 320, 80)];
    scrollViewProgrammatically.dataSource = self;
    scrollViewProgrammatically.layer.masksToBounds = NO;
    scrollViewProgrammatically.layer.shadowOffset = CGSizeMake(-2, 5);
    scrollViewProgrammatically.layer.shadowRadius = 5;
    scrollViewProgrammatically.layer.shadowOpacity = 0.5;
    [self.view addSubview:scrollViewProgrammatically];
}

#pragma mark - RTInfiniteScrollViewDataSource protocol

- (UIView *)infiniteScrollView:(RTInfiniteScrollView *)infiniteScrollView tileForIndex:(NSInteger)index
{
    UILabel *tileView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 80)];

    [tileView setNumberOfLines:2];
    [tileView setText:[NSString stringWithFormat:@"Index:\n%d", index]];
    
    return tileView;
}


@end
