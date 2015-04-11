//
//  LGPlayerViewController.m
//  LGPlayer
//
//  Created by Jinxiang on 13-10-12.
//  Copyright (c) 2013年 Jinxiang. All rights reserved.
//

#import "LGPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define NLSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
#define IOS7 NLSystemVersionGreaterOrEqualThan(7.0)

@interface LGPlayerViewController ()

@end

@implementation LGPlayerViewController
@synthesize movieUrl = _movieUrl,movieName = _movieName,movieDownUrl = _movieDownUrl;
@synthesize isPlaying;
@synthesize frameChange;
@synthesize progressView = _progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_LGCustomMoviePlayerController.player play];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    movieNameLabel.text = self.movieName;
    _movieProgressSlider.value = 0;
    //使用playerItem获取视频的信息，当前播放时间，总时间等
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.movieUrl]];
    //player是视频播放的控制器，可以用来快进播放，暂停等
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_LGCustomMoviePlayerController.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [_LGCustomMoviePlayerController setPlayer:player];
    [_LGCustomMoviePlayerController.player play];
    _LGCustomMoviePlayerController.player.allowsAirPlayVideo = YES;
    _LGCustomMoviePlayerController.delegate = self;
    isPlaying = YES;
    if (!IOS7)
    {
        //计算视频总时间
        CMTime totalTime = playerItem.duration;
        //因为slider的值是小数，要转成float，当前时间和总时间相除才能得到小数,因为5/10=0
        totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:totalMovieDuration];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if (totalMovieDuration/3600 >= 1) {
            [formatter setDateFormat:@"HH:mm:ss"];
        }
        else
        {
            [formatter setDateFormat:@"mm:ss"];
        }
        NSString *showtimeNew = [formatter stringFromDate:d];
        NSLog(@"totalMovieDuration:%@",showtimeNew);
        //在totalTimeLabel上显示总时间
        self.durationLabel.text = showtimeNew;
    }
    //检测视频加载状态，加载完成隐藏风火轮
    [_LGCustomMoviePlayerController.player.currentItem addObserver:self forKeyPath:@"status"
                                           options:NSKeyValueObservingOptionNew
                                           context:nil];
    [_LGCustomMoviePlayerController.player.currentItem  addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    //添加视频播放完成的notifation
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_LGCustomMoviePlayerController.player.currentItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil];

    [self monitorMovieProgress];

    self.reminderView.hidden = YES;
    CALayer *lay  = self.reminderView.layer;//获取层
    [lay setMasksToBounds:YES];
    [lay setCornerRadius:10];     //值越大，角度越圆

    self.CommentView.frame = CGRectMake(755 + 269, 20, 269, 664);
    isComment = NO;
    
    
    /*
     视频播放时，控制手势，双击放大缩小播放比例
     双指缩放播放比例
     */
    //轻触手势（单击，双击）
    UITapGestureRecognizer *oneTap=nil;
    oneTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneTap:)];
    oneTap.numberOfTapsRequired = 1;
    [_LGCustomMoviePlayerController addGestureRecognizer:oneTap];
    [oneTap release];

    UITapGestureRecognizer *tapCgr=nil;
    tapCgr=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TwoTap:)];
    tapCgr.numberOfTapsRequired = 2;
    [_LGCustomMoviePlayerController addGestureRecognizer:tapCgr];
    [tapCgr release];
    
    [oneTap requireGestureRecognizerToFail:tapCgr]; //防止：双击被单击拦截
//    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
//    [_LGCustomMoviePlayerController addGestureRecognizer:pinchGestureRecognizer];
}

- (void) oneTap:(UITapGestureRecognizer *)sender
{
    if (isPlaying == YES)
    {
        isPlaying = NO;
        [_LGCustomMoviePlayerController.player pause];
    }
    else
    {
        isPlaying = YES;
        [_LGCustomMoviePlayerController.player play];
    }
}

//双击放大或缩小播放比例
- (void) TwoTap:(UITapGestureRecognizer *)sender
{
    if (frameChange == NO)
    {
        _LGCustomMoviePlayerController.frame = CGRectMake(-290.5, -117.025, 1024*1.5, 615*1.5);
        frameChange = YES;
    }
    else
    {
        _LGCustomMoviePlayerController.frame = CGRectMake(0, 69, 1024, 615);
        frameChange = NO;
    }
}

- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    frameChange = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)downBtn:(id)sender {
    
}

- (IBAction)BackBtn:(id)sender
{
    [_LGCustomMoviePlayerController.player pause];
    isPlaying = NO;
}

- (IBAction)PlayAndStopBtn:(id)sender {
    if (isPlaying == YES)
    {
        [_LGCustomMoviePlayerController.player pause];
        isPlaying = NO;
    }
    else
    {
        [_LGCustomMoviePlayerController.player play];
        isPlaying = YES;
    }
}


- (IBAction)speedDownBtn:(id)sender
{
    [_LGCustomMoviePlayerController.player pause];
    //获取当前时间
    CMTime currentTime = _LGCustomMoviePlayerController.player.currentItem.currentTime;
    //转成秒数
    currentDuration = (CGFloat)currentTime.value/currentTime.timescale;
}
- (IBAction)retreatDownBtn:(id)sender
{
    [_LGCustomMoviePlayerController.player pause];
    CMTime currentTime = _LGCustomMoviePlayerController.player.currentItem.currentTime;
    //转成秒数
    currentDuration = (CGFloat)currentTime.value/currentTime.timescale;
}

- (IBAction)speedBtn:(id)sender
{
    self.reminderView.hidden = NO;
    self.reminderLabel.text = @"快进30秒";
    PlayStyeimageView.image = [UIImage imageNamed:@"speed.png"];
    [self performSelector:@selector(hideReminderView) withObject:self afterDelay:0.5];
    float bufferTime = [self availableDuration];
    float durationTime = CMTimeGetSeconds([[self.LGCustomMoviePlayerController.player currentItem] duration]);
    [self.progressView setProgress:bufferTime/durationTime animated:YES];
    [self speed];
}

- (IBAction)retreatBtn:(id)sender
{
    self.reminderView.hidden = NO;
    self.reminderLabel.text = @"快退30秒";
    PlayStyeimageView.image = [UIImage imageNamed:@"retreat.png"];
    [self performSelector:@selector(hideReminderView) withObject:self afterDelay:0.5];
    float bufferTime = [self availableDuration];
    float durationTime = CMTimeGetSeconds([[self.LGCustomMoviePlayerController.player currentItem] duration]);
    [self.progressView setProgress:bufferTime/durationTime animated:YES];
    [self retreat];
}

- (IBAction)CommentBtn:(id)sender
{
    if (isComment == YES)
    {
        isComment = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.CommentView.frame = CGRectMake(755 + 269, 20, 269, 664);
        [UIView commitAnimations];
    }
    else
    {
        isComment = YES;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.CommentView.frame = CGRectMake(755, 20, 269, 664);
        [UIView commitAnimations];
    }
}

- (void) speed
{
    CGFloat newTime = currentDuration + 30;
    if (newTime >= totalMovieDuration)
    {
        if (isPlaying == YES)
        {
            [_LGCustomMoviePlayerController.player play];
        }
        return;
    }
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(newTime, 1);
    [self.Moviebuffer startAnimating];
    self.Moviebuffer.hidden = NO;
    [_LGCustomMoviePlayerController.player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish)
     {
         [_LGCustomMoviePlayerController.player play];
         [self.Moviebuffer stopAnimating];
         self.Moviebuffer.hidden = YES;
     }];
    isPlaying = YES;
}
- (void) retreat
{
    CGFloat newTime = currentDuration - 30;
    if (newTime <= 0.0)
    {
        if (isPlaying == YES)
        {
            [_LGCustomMoviePlayerController.player play];
        }
        return;
    }
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(newTime, 1);
    [self.Moviebuffer startAnimating];
    self.Moviebuffer.hidden = NO;
    [_LGCustomMoviePlayerController.player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish)
     {
         [_LGCustomMoviePlayerController.player play];
         [self.Moviebuffer stopAnimating];
         self.Moviebuffer.hidden = YES;
     }];
    isPlaying = YES;
}

-(void)monitorMovieProgress{
    [self.Moviebuffer startAnimating];
    //使用movieProgressSlider反应视频播放的进度
    //第一个参数反应了检测的频率
    [_LGCustomMoviePlayerController.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
        //获取当前时间
        CMTime currentTime = _LGCustomMoviePlayerController.player.currentItem.currentTime;
        //转成秒数
        CGFloat currentPlayTime = (CGFloat)currentTime.value/currentTime.timescale;
        _movieProgressSlider.value = currentPlayTime/totalMovieDuration;
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:currentPlayTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if (currentPlayTime/3600 >= 1) {
            [formatter setDateFormat:@"HH:mm:ss"];
        }
        else
        {
            [formatter setDateFormat:@"mm:ss"];
        }
        NSString *showtime = [formatter stringFromDate:d];
        self.currentTimeLabel.text = showtime;
    }];
    
    //左右轨的图片
    UIImage *stetchLeftTrack = [[UIImage imageNamed:@"播放器_13.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    UIImage *stetchRightTrack = [[UIImage imageNamed:@"rigth.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"slider-metal-handle.png"];
    
    if (IOS7)
    {
        self.movieProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(6, 673, 1015.5, 12)];
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(6, 688.5, 1015.5, 15)];
    }
    else
    {
        self.movieProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(6, 678.5, 1015.5, 12)];
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(6.5, 686.5, 1015.5, 3)];
    }

    _progressView.progressTintColor = [UIColor blackColor];
    _progressView.trackTintColor = [UIColor clearColor];
    [self.progressView setProgress:0 animated:NO];
    [self.view addSubview:_progressView];

    [self.view addSubview:self.movieProgressSlider];
    [self.movieProgressSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [self.movieProgressSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    self.movieProgressSlider.backgroundColor = [UIColor clearColor];
    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
    [self.movieProgressSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.movieProgressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.movieProgressSlider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
    [self.movieProgressSlider addTarget:self action:@selector(scrubberIsScrolling) forControlEvents:UIControlEventValueChanged];
    [self.movieProgressSlider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
}

//按动滑块
-(void)scrubbingDidBegin
{
    [_LGCustomMoviePlayerController.player pause];
}

//快进
-(void)scrubberIsScrolling
{
    double currentTime = floor(totalMovieDuration *self.movieProgressSlider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [_LGCustomMoviePlayerController.player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish)
    {
        if (isPlaying == YES)
        {
            [_LGCustomMoviePlayerController.player play];
        }
        [self.Moviebuffer stopAnimating];
        self.Moviebuffer.hidden = YES;
    }];
}

-(void)scrubbingDidEnd
{
    self.Moviebuffer.hidden = NO;
    [_Moviebuffer startAnimating];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        if (playerItem.status==AVPlayerStatusReadyToPlay) {
            //视频加载完成
            [self.Moviebuffer stopAnimating];
            self.Moviebuffer.hidden = YES;
            if (IOS7)
            {
                //计算视频总时间
                CMTime totalTime = playerItem.duration;
                totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
                NSDate *d = [NSDate dateWithTimeIntervalSince1970:totalMovieDuration];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                if (totalMovieDuration/3600 >= 1) {
                    [formatter setDateFormat:@"HH:mm:ss"];
                }
                else
                {
                    [formatter setDateFormat:@"mm:ss"];
                }
                NSString *showtimeNew = [formatter stringFromDate:d];
                self.durationLabel.text = showtimeNew;
            }
         }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
        float bufferTime = [self availableDuration];
        NSLog(@"缓冲进度%f",bufferTime);
        float durationTime = CMTimeGetSeconds([[self.LGCustomMoviePlayerController.player currentItem] duration]);
        [self.progressView setProgress:bufferTime/durationTime animated:YES];
    }

}

//加载进度
- (float)availableDuration
{
    NSArray *loadedTimeRanges = [[self.LGCustomMoviePlayerController.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}

-(void)moviePlayDidEnd:(NSNotification*)notification{
    //视频播放完成
    NSLog(@"播放完成 加入广告");
}

-(void)applicationWillResignActive:(NSNotification *)notification
{
    isPlaying = NO;
    NSLog(@"进入后台");
}

- (void) Touchspeed
{
    //获取当前时间
    CMTime currentTime = _LGCustomMoviePlayerController.player.currentItem.currentTime;
    //转成秒数
    currentDuration = (CGFloat)currentTime.value/currentTime.timescale;
    CGFloat newTime = currentDuration + 30;
    if (newTime >= totalMovieDuration)
    {
        return;
    }
    self.reminderView.hidden = NO;
    self.reminderLabel.text = @"快进30秒";
    PlayStyeimageView.image = [UIImage imageNamed:@"speed.png"];
    [self performSelector:@selector(hideReminderView) withObject:self afterDelay:0.5];
    [self speed];
}

- (void) Touchretreat
{
    //获取当前时间
    CMTime currentTime = _LGCustomMoviePlayerController.player.currentItem.currentTime;
    //转成秒数
    currentDuration = (CGFloat)currentTime.value/currentTime.timescale;
    CGFloat newTime = currentDuration - 30;
    if (newTime <= 0.0)
    {
        return;
    }
    self.reminderView.hidden = NO;
    self.reminderLabel.text = @"快退30秒";
    PlayStyeimageView.image = [UIImage imageNamed:@"retreat.png"];
    [self performSelector:@selector(hideReminderView) withObject:self afterDelay:0.5];
    [self retreat];
}

- (void) hideReminderView
{
    self.reminderView.hidden = YES;
}

- (void)dealloc {
    [_currentTimeLabel release];
    [_durationLabel    release];
    [_movieUrl         release];
    [_movieDownUrl     release];
    [_movieName        release];
    [_LGCustomMoviePlayerController release];
    [_movieProgressSlider release];
    [_Moviebuffer release];
    [_reminderView release];
    [_reminderLabel release];
    [_CommentView release];
    [_progressView release];
    
    //释放对视频播放完成的监测
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_LGCustomMoviePlayerController.player.currentItem];
    //释放掉对playItem的观察
    [_LGCustomMoviePlayerController.player.currentItem removeObserver:self
                                                           forKeyPath:@"status"
                                                              context:nil];
    [_LGCustomMoviePlayerController.player.currentItem removeObserver:self
                                                           forKeyPath:@"loadedTimeRanges"
                                                              context:nil];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];

    [PlayStyeimageView release];
    [movieNameLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCurrentTimeLabel:nil];
    [self setDurationLabel:nil];
    [self setLGCustomMoviePlayerController:nil];
    [self setMovieProgressSlider:nil];
    [self setMoviebuffer:nil];
    [self setReminderView:nil];
    [self setReminderLabel:nil];
    [self setCommentView:nil];
    [PlayStyeimageView release];
    PlayStyeimageView = nil;
    [movieNameLabel release];
    movieNameLabel = nil;
    [super viewDidUnload];
}
@end
