//
//  ViewController.h
//  tvOSDemoApp
//
//  Created by Ales Teska on 26/02/16.
//
//

#import <UIKit/UIKit.h>
#import "SeaCatiOSClient/SeaCatClient.h"

@interface ViewController : UIViewController <SeaCatPingDelegate>;
@property (weak, nonatomic) IBOutlet UILabel *pingLabel;


@end

