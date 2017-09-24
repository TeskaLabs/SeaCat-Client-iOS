//
//  SplashViewController.m
//  SeaCatClient
//
//  Created by Ales Teska on 28/02/16.
//
//

#import "SplashViewController.h"
#import "SeaCatiOSClient/SeaCat.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
{
    NSTimer * periodicTimer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

///

- (void)viewWillAppear:(BOOL)animated
{
    if ([SeaCat isReady]) [self dismissViewControllerAnimated:YES completion:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [SeaCat addObserver:self selector:@selector(onStateChanged) name:SeaCat_Notification_StateChanged];
    periodicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onStateChanged) userInfo:nil repeats:YES];
    [self onStateChanged];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SeaCat removeObserver:self];

    [periodicTimer invalidate];
    periodicTimer = nil;

    [super viewWillAppear:animated];
}

///

- (void)onStateChanged
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * state = [SeaCat getState];
        [_stateItem setTitle:state];
        
        // SeaCat is ready
        if ([SeaCat isReady]) [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

///

- (IBAction)onResetAction:(id)sender
{
    UIAlertController *myAlertController = [UIAlertController
        alertControllerWithTitle:@"Reset identity"
        message: @"Are you sure?"
        preferredStyle:UIAlertControllerStyleAlert
    ];
    
    UIAlertAction* act_yes = [UIAlertAction
        actionWithTitle:@"Yes"
        style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction * action)
        {
            [SeaCat reset];
            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        }
    ];
    [myAlertController addAction:act_yes];
    
    UIAlertAction* act_no = [UIAlertAction
        actionWithTitle:@"No"
        style:UIAlertActionStyleCancel
        handler:^(UIAlertAction * action)
        {
            [myAlertController dismissViewControllerAnimated:YES completion:nil];
        }
    ];
    [myAlertController addAction:act_no];
    
    [self presentViewController:myAlertController animated:YES completion:nil];
}

@end
