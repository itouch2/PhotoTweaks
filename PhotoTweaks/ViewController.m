//
//  ViewController.m
//  PhotoTweaks
//
//  Created by Tu You on 14/11/28.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "ViewController.h"
#import "PhotoView.h"

@interface ViewController ()

@property (strong, nonatomic) PhotoView *photoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

    UIImage *image0 = [UIImage imageNamed:@"photo"];
    UIImage *image1 = [UIImage imageNamed:@"brave-pixar-poster.jpg"];
    
    self.photoView = [[PhotoView alloc] initWithFrame:self.view.bounds image:image1];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.photoView];
    
    UIView *t = [UIView new];
    t.backgroundColor = [UIColor redColor];
    t.frame = CGRectMake(20, 20, 100, 100);
    t.transform = CGAffineTransformMakeRotation(M_PI_2 / 8);
    NSLog(@"%@", NSStringFromCGRect(t.frame));
    NSLog(@"%@", NSStringFromCGRect(t.bounds));
    
    t.frame = CGRectMake(20, 20, 100, 100);
    NSLog(@"%@", NSStringFromCGRect(t.frame));
    NSLog(@"%@", NSStringFromCGRect(t.bounds));
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 400, 60, 20)];
    [btn setTitle:@"zoom" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
}

- (void)btnClicked:(id)sender
{
    [self.photoView zoom];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
