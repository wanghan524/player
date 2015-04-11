//
//  CustomPlayerView.h
//  VideoStreamDemo2
//
//  Created by 刘 大兵 on 12-5-17.
//  Copyright (c) 2012年 中华中等专业学校. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol EveryFrameDelegate <NSObject>
- (void) Touchspeed;
- (void) Touchretreat;
@end

@interface CustomPlayerView : UIView
{
    float x;
    float y;
    float volume;
    id    delegate;
}
@property(nonatomic,retain) AVPlayer *player;
@property(nonatomic,assign) float     volume;
@property (nonatomic,assign) id      delegate;

@end
