//
//  ViewController.m
//  iOSDemoApp
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

- (void)viewDidLoad
{
    [super viewDidLoad];
}

///

- (void)viewWillAppear:(BOOL)animated
{
    [self onStateChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![SeaCat isReady])
    {
        [self performSegueWithIdentifier:@"SeaCatSpashSeque" sender:self];
        return;
    }

    taskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTaskTimer) userInfo:nil repeats:YES];
    [SeaCat addObserver:self selector:@selector(onStateChanged) name:SeaCat_Notification_StateChanged];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SeaCat removeObserver:self];

    [taskTimer invalidate];
    taskTimer = nil;
    
    [super viewWillDisappear:animated];
}

///

-(void)onTaskTimer
{
    [self onStateChanged];
    [SeaCat ping:self];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self taskURLRequest_GET];
    });
}

- (void)onStateChanged
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _stateLabel.text = [SeaCat getState];
    }];
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


-(void)taskURLRequest_GET
{
    NSMutableString *urlString = [NSMutableString stringWithString:@"http://evalhost.seacat/fortune"];
    [urlString appendFormat:@"?%@", [[NSBundle mainBundle] bundleIdentifier]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSString * resultText = @"????";
         if (response != NULL)
         {
             //resultText = [NSString stringWithFormat:@"%@", response];
             resultText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         }
         
         else
         {
             NSLog(@"NSURLConnection error: %@\n", connectionError);
             resultText = [NSString stringWithFormat:@"NSURLConnection error:\n%ld\n%@", (long)connectionError.code, connectionError];
         }
         
         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
             [_resultLabel setText:resultText];
             [_resultLabel sizeToFit];
         }];
         
     }];
}

@end
