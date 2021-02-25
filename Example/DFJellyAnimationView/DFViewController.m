//
//  DFViewController.m
//  DFJellyAnimationView
//
//  Created by dzwing on 02/25/2021.
//  Copyright (c) 2021 dzwing. All rights reserved.
//

#import "DFViewController.h"
#import "DFJellyAnimationView.h"

@interface DFViewController ()

@end

@implementation DFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DFJellyAnimationView *jellyView = [[DFJellyAnimationView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:jellyView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
