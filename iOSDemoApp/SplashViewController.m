//
//  SplashViewController.m
//  SeaCatClient
//
//  Created by Ales Teska on 28/02/16.
//
//

#import "SplashViewController.h"
#import "SeaCatClient/SeaCatClient.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
{
    NSTimer * periodicTimer;
}

///

- (void)viewWillAppear:(BOOL)animated
{
    if ([SeaCatClient isReady]) [self dismissViewControllerAnimated:YES completion:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [SeaCatClient addObserver:self selector:@selector(onStateChanged) name:SeaCat_Notification_StateChanged];
    periodicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onStateChanged) userInfo:nil repeats:YES];
    [self onStateChanged];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SeaCatClient removeObserver:self];

    [periodicTimer invalidate];
    periodicTimer = nil;

    [super viewWillDisappear:animated];
}

///

- (void)onStateChanged
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString * state = [SeaCatClient getState];
        [_stateItem setTitle:state];
        
        _clientTagLabel.text = [SeaCatClient getClientTag];
        
        // SeaCat is ready
        if ([SeaCatClient isReady]) [self dismissViewControllerAnimated:YES completion:nil];
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
            [SeaCatClient reset];
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
