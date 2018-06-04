//
//  ViewController.m
//  iOSDemoApp
//
//  Created by Ales Teska on 26/02/16.
//
//

#import "ViewController.h"
#import <CommonCrypto/CommonCryptor.h>

@interface ViewController ()
{
    NSTimer * taskTimer;
}

@end

@implementation ViewController

///

- (void)viewWillAppear:(BOOL)animated
{
    [self onStateChanged];
    [self onClientIdChanged];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![SeaCatClient isReady])
    {
        [self performSegueWithIdentifier:@"SeaCatSpashSeque" sender:self];
        return;
    }

    taskTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTaskTimer) userInfo:nil repeats:YES];
    [SeaCatClient addObserver:self selector:@selector(onStateChanged) name:SeaCat_Notification_StateChanged];
    [SeaCatClient addObserver:self selector:@selector(onClientIdChanged) name:SeaCat_Notification_ClientIdChanged];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [SeaCatClient removeObserver:self];

    [taskTimer invalidate];
    taskTimer = nil;
    
    [super viewWillDisappear:animated];
}

///

-(void)onTaskTimer
{
    [self onStateChanged];
    [SeaCatClient ping:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self taskURLSession_GET];
        [self task_AES];
        //[self taskURLSession_POST];
    });

}

- (void)onStateChanged
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _stateLabel.text = [SeaCatClient getState];
    }];
}

- (void)onClientIdChanged
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _clientTagLabel.text = [SeaCatClient getClientTag];
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
    NSMutableString *urlString = [NSMutableString stringWithString:@"http://jsontest.seacat/"];
    //NSMutableString *urlString = [NSMutableString stringWithString:@"http://example.com/"];
    //[urlString appendFormat:@"?%@", [[NSBundle mainBundle] bundleIdentifier]];
    
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

-(void)taskURLSession_GET
{
    //NSURL *url = [NSURL URLWithString:@"http://example.com/"];
    //NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURL *url = [NSURL URLWithString:@"http://jsontest.seacat/"];
    NSURLSessionConfiguration * configuration = [SeaCatClient getNSURLSessionConfiguration];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"GET"];
    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError)
    {
        NSString * resultText = @"????";
        if (response != NULL)
        {
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
    
    [task resume];
}


-(void)taskURLSession_POST
{
    //NSURL *url = [NSURL URLWithString:@"http://example.com/"];
    //NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURL *url = [NSURL URLWithString:@"http://evalhost.seacat/"];
    NSURLSessionConfiguration * configuration = [SeaCatClient getNSURLSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    request.HTTPMethod =  @"POST";
    request.HTTPBody = [@"Body ..." dataUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionDataTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError)
                                   {
                                       NSString * resultText = @"????";
                                       if (response != NULL)
                                       {
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
    
    [task resume];
}

-(void)task_AES
{
    NSData * key = [SeaCatClient deriveKey:@"aes-key-1" keyLength:32];
    
    size_t outLength;
    NSData * rawData = [@"Hello world" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *cipherData = [NSMutableData dataWithLength:512];
    NSMutableData *outData = [NSMutableData dataWithLength:512];
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES, kCCOptionPKCS7Padding | kCCModeCBC,
                                     key.bytes, key.length,
                                     "", // IV
                                     rawData.bytes, rawData.length,
                                     cipherData.mutableBytes, cipherData.length,
                                     &outLength
                                     );
    assert(result == kCCSuccess);
    
    result = CCCrypt(kCCDecrypt,
                     kCCAlgorithmAES, kCCOptionPKCS7Padding | kCCModeCBC,
                     key.bytes, key.length,
                     "", // IV
                     cipherData.mutableBytes, outLength,
                     outData.mutableBytes, outData.length,
                     &outLength
                     );
    assert(result == kCCSuccess);
}

@end
