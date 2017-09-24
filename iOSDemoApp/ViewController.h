//
//  ViewController.h
//  iOSDemoApp
//
//  Created by Ales Teska on 26/02/16.
//
//

#import <UIKit/UIKit.h>
#import "SeaCatiOSClient/SeaCat.h"

@interface ViewController : UIViewController <SeaCatPingDelegate>;

@property (weak, nonatomic) IBOutlet UILabel *pingLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

