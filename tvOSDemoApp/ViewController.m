//
//  ViewController.m
//  tvOSDemoApp
//
//  Created by Ales Teska on 26/02/16.
//
//

#import "ViewController.h"

@interface ViewController ()
{
    NSTimer * taskTimer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    taskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onPingTimer) userInfo:nil repeats:YES];
}

-(void)onTaskTimer
{
    [SeaCatClient ping:self];
}

-(void)pong:(int32_t)pingId;
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_pingLabel setText:[NSString stringWithFormat:@"Ping received: %d", pingId]];
    }];
}

-(void)pingCanceled:(int32_t)pingId
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_pingLabel setText:@"Ping failed :-("];
    }];
}

@end
