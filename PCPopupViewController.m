//
//  PCPopupViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 26/03/14.
//  Copyright (c) 2014 Paulo Cristo. All rights reserved.
//

#import "PCPopupViewController.h"

@interface PCPopupViewController ()


@end


@implementation PCPopupViewController

@synthesize imageView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.alpha=0;
    
    //self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame),400);
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void) viewDidLayoutSubviews {
    //self.view.frame = CGRectMake(0, 0, 257, CGRectGetHeight(self.view.frame));
  //  self.view.alpha=0.5;
//}

-(void) viewWillAppear:(BOOL)animated{
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    imageView.alpha=1;
}

- (IBAction)closeClicked:(id)sender {
    [self.view removeFromSuperview];
}





@end
