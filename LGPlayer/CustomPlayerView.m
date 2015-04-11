//
//  CustomPlayerView.m
//  VideoStreamDemo2
//
//  Created by 刘 大兵 on 12-5-17.
//  Copyright (c) 2012年 中华中等专业学校. All rights reserved.
//

#import "CustomPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
@implementation CustomPlayerView
@synthesize volume;
@synthesize delegate;
+(Class)layerClass{
    return [AVPlayerLayer class];
}

-(AVPlayer*)player{
    return [(AVPlayerLayer*)[self layer]player];
}

-(void)setPlayer:(AVPlayer *)thePlayer{
    return [(AVPlayerLayer*)[self layer]setPlayer:thePlayer];
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"began %f==%f",touchPoint.x,touchPoint.y);
    x = (touchPoint.x);
    y = (touchPoint.y);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"end %f==%f",touchPoint.x,touchPoint.y);
    if ((touchPoint.x - x) >= 50 && (touchPoint.y - y) <= 20 && (touchPoint.y - y) >= -20)
    {
        NSLog(@"快进");
        if ([delegate respondsToSelector:@selector(Touchspeed)])
        {
            [delegate Touchspeed];
        }
    }
    if ((touchPoint.x - x) >= 50 && (y - touchPoint.y) <= 50 && (y - touchPoint.y) >= -50)
    {
        NSLog(@"快进");
        if ([delegate respondsToSelector:@selector(Touchspeed)])
        {
            [delegate Touchspeed];
        }
    }
    if ((x - touchPoint.x) >= 50 && (touchPoint.y - y) <= 50 && (touchPoint.y - y) >= -50)
    {
        NSLog(@"快退");
        if ([delegate respondsToSelector:@selector(Touchretreat)])
        {
            [delegate Touchretreat];
        }

    }
    if ((x - touchPoint.x) >= 50 && (y - touchPoint.y) <= 50 && (y - touchPoint.y) >= -50)
    {
        NSLog(@"快退");
        if ([delegate respondsToSelector:@selector(Touchretreat)])
        {
            [delegate Touchretreat];
        }
        
    }
    if ((touchPoint.y - y) >= 50 && (touchPoint.x - x) <= 50 && (touchPoint.x - x) >= -50)
    {
        NSLog(@"减小音量 1/10");
        MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
        if ((mpc.volume - 0.1) <= 0)
        {
            mpc.volume = 0;
        }
        else
        {
            mpc.volume = mpc.volume - 0.05;
        }
    }
    if ((y - touchPoint.y) >= 50)
    {
        NSLog(@"加大音量");
        MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
        if ((mpc.volume + 0.1) >= 1)
        {
            mpc.volume = 1;
        }
        else
        {
            mpc.volume = mpc.volume + 0.05;
        }

    }
}

@end
