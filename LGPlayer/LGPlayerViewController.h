//
//  LGPlayerViewController.h
//  LGPlayer
//
//  Created by Jinxiang on 13-10-12.
//  Copyright (c) 2013年 Jinxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPlayerView.h"

@interface LGPlayerViewController : UIViewController
{
    NSString *_movieUrl;
    NSString *_movieName;
    NSString *_movieDownUrl;
    CGFloat  totalMovieDuration;
    CGFloat  currentDuration;
    UISlider *_movieProgressSlider;
    UIProgressView  *_progressView;
    BOOL     isPlaying;
    BOOL     isComment;
    BOOL     frameChange;
    IBOutlet UIImageView *PlayStyeimageView;
    IBOutlet UILabel *movieNameLabel;
}

@property (retain, nonatomic) IBOutlet CustomPlayerView *LGCustomMoviePlayerController;
@property (retain, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *durationLabel;
@property (retain, nonatomic) NSString *movieUrl;
@property (retain, nonatomic) NSString *movieName;
@property (retain, nonatomic) NSString *movieDownUrl;
@property (retain, nonatomic) UISlider *movieProgressSlider;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *Moviebuffer;
@property (assign, nonatomic) BOOL     isPlaying;
@property (assign, nonatomic) BOOL     frameChange;
@property (retain, nonatomic) IBOutlet UIView *reminderView;
@property (retain, nonatomic) IBOutlet UILabel *reminderLabel;
@property (retain, nonatomic) IBOutlet UIView *CommentView;
@property (retain, nonatomic) UIProgressView  *progressView;
- (IBAction)downBtn:(id)sender;
- (IBAction)BackBtn:(id)sender;
- (IBAction)PlayAndStopBtn:(id)sender;
- (IBAction)speedBtn:(id)sender;
- (IBAction)speedDownBtn:(id)sender;
- (IBAction)retreatDownBtn:(id)sender;

- (IBAction)retreatBtn:(id)sender;
- (IBAction)CommentBtn:(id)sender;

- (void) speed;
- (void) retreat;
@end
