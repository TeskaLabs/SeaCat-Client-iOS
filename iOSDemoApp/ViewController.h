//
//  ViewController.h
//  iOSDemoApp
//
//  Created by Ales Teska on 26/02/16.
//
//

#import <UIKit/UIKit.h>
#import "SeaCatClient/SeaCatClient.h"

@interface ViewController : UIViewController <SeaCatPingDelegate>;

@property (weak, nonatomic) IBOutlet UILabel *pingLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *clientTagLabel;

@end

