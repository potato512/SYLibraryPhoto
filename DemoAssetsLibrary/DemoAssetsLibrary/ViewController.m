//
//  ViewController.m
//  DemoAssetsLibrary
//
//  Created by zhangshaoyu on 15/4/15.
//  Copyright (c) 2015年 zhangshaoyu. All rights reserved.
//

#import "ViewController.h"
#import "PhotoHelper.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) PhotoHelper *photoHelper;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"相册图片";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStyleDone target:self action:@selector(removePhotoScrollViewSubview)];
    
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setUI
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.photoScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.photoScrollView];
    self.photoScrollView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    self.photoScrollView.frame = CGRectMake(10.0, 10.0, self.view.frame.size.width - 10.0 * 2, 80.0);
    self.photoScrollView.layer.borderColor = [UIColor greenColor].CGColor;
    self.photoScrollView.layer.borderWidth = 1.0;
    
    self.activityView = [[UIActivityIndicatorView alloc] init];
    [self.view addSubview:self.activityView];
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.activityView.center = self.photoScrollView.center;
    [self resetActivityView:NO];
    
    NSArray *array = [NSArray arrayWithObjects:@"first", @"last 1", @"last 2", @"all", @"最早n张图", @"最新n张图", nil];
    NSInteger count = array.count;
    for (int i = 0; i < count; i++)
    {
        NSString *title = array[i];
        CGRect rect = CGRectMake(10.0, i * (40.0 + 10.0) + 100.0, self.view.frame.size.width - 10.0 * 2, 40.0);
        
        UIButton *button = [[UIButton alloc] init];
        [self.view addSubview:button];
        button.frame = rect;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        button.backgroundColor = [UIColor orangeColor];
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)removePhotoScrollViewSubview
{
    for (UIImageView *view in self.photoScrollView.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void)resetPhotoScrollView:(NSArray *)images
{
    if (images && 0 != images.count)
    {
        CGFloat sizeWidth = 0.0;
        int i = 0;
        for (UIImage *image in images)
        {
            UIImageView *imageview = [[UIImageView alloc] init];
            [self.photoScrollView addSubview:imageview];
            imageview.image = image;
            imageview.frame = CGRectMake(i * (80.0 + 5.0) + 5.0, 0.0, 80.0, 80.0);
            
            i++;
            sizeWidth = imageview.frame.origin.x + imageview.frame.size.width + 5.0;
        }
        
        self.photoScrollView.contentSize = CGSizeMake(sizeWidth, self.photoScrollView.frame.size.height);
    }
}

- (void)resetActivityView:(BOOL)show
{
    if (show)
    {
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
    }
    else
    {
        self.activityView.hidden = YES;
        [self.activityView stopAnimating];
    }
}

- (void)buttonClick:(UIButton *)button
{
    if (!self.photoHelper)
    {
        self.photoHelper = [[PhotoHelper alloc] init];
    }
    
    [self removePhotoScrollViewSubview];
    
    __weak ViewController *weakSelf = self;
    NSInteger index = button.tag;
    if (0 == index)
    {
        [self.photoHelper GetImageFirst:^(NSArray *images) {
            [weakSelf resetPhotoScrollView:images];
        } error:^{
            NSLog(@"error get first image");
        }];
    }
    else if (1 == index)
    {
        [self.photoHelper GetImagelast:^(NSArray *images) {
            [weakSelf resetPhotoScrollView:images];
        } error:^{
            NSLog(@"error get last image");
        }];
    }
    else if (2 == index)
    {
        [self.photoHelper GetImagelastSec:^(NSArray *images) {
            [weakSelf resetPhotoScrollView:images];
        } error:^{
            NSLog(@"error get last image");
        }];
    }
    else if (3 == index)
    {
        [self.photoHelper GetImagesWithNum:0 latest:YES start:^{
            [weakSelf resetActivityView:YES];
        } success:^(NSArray *images) {
            [weakSelf resetActivityView:NO];
            [weakSelf resetPhotoScrollView:images];
        } error:^{
            NSLog(@"error get last image");
        }];
    }
    else if (4 == index)
    {
        [self.photoHelper GetImagesWithNum:10 latest:NO start:^{
            [weakSelf resetActivityView:YES];
        } success:^(NSArray *images) {
            [weakSelf resetActivityView:NO];
            [weakSelf resetPhotoScrollView:images];
        } error:^{
            NSLog(@"error get last image");
        }];
    }
    else if (5 == index)
    {
        [self.photoHelper GetImagesWithNum:10 latest:YES start:^{
            [weakSelf resetActivityView:YES];
        } success:^(NSArray *images) {
            [weakSelf resetActivityView:NO];
            [weakSelf resetPhotoScrollView:images];
        } error:^{
            NSLog(@"error get last image");
        }];
    }
}

@end
