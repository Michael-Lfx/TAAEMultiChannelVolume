//
//  ViewController.m
//  taaeTest2
//
//  Created by Sander on 12/30/14.
//  Copyright (c) 2014 Sander. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Turn the sliders vertical
    UIView *superView = self.slider1.superview;
    [self.slider1 removeFromSuperview];
    [self.slider1 removeConstraints:self.view.constraints];
    self.slider1.translatesAutoresizingMaskIntoConstraints = YES;
    self.slider1.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [superView addSubview:self.slider1];
    [self.slider2 removeFromSuperview];
    [self.slider2 removeConstraints:self.view.constraints];
    self.slider2.translatesAutoresizingMaskIntoConstraints = YES;
    self.slider2.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [superView addSubview:self.slider2];
    

    //initialize and start the audio controller
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled: YES];
    _audioController.preferredBufferDuration = 0.005;
    
    NSError *error = [NSError alloc];
    if(![self.audioController start:&error]){
        NSLog(@"Error starting AudioController: %@", error.localizedDescription);
    }
    
   
    //Add audio output channels and input receiver
    player1 = [[MyAudioPlayer alloc] init];
    player2 = [[MyAudioPlayer alloc] init];

    channel1 = [self.audioController createChannelGroup];
    channel2 = [self.audioController createChannelGroup];
    
    [self.audioController addInputReceiver:self];
    [self.audioController addChannels:[[NSArray alloc] initWithObjects:player1, nil] toChannelGroup:channel1];
    [self.audioController addChannels:[[NSArray alloc] initWithObjects:player2, nil] toChannelGroup:channel2];
    
    //Initialize volumes
    volumes = (float *)malloc(sizeof(float) * 2);
    volumes[0] = self.slider1.value;
    volumes[1] = self.slider2.value;
    [self.audioController setVolume:volumes[0] forChannelGroup:channel1];
    [self.audioController setVolume:volumes[1] forChannelGroup:channel2];
    
    
//    AudioStreamBasicDescription asbd = [self.audioController inputAudioDescription];
//    [self.audioController set
    
}

static void inputCallback(__unsafe_unretained ViewController *THIS,
                          __unsafe_unretained AEAudioController *audioController,
                          void                     *source,
                          const AudioTimeStamp     *time,
                          UInt32                    frames,
                          AudioBufferList          *audio) {
    
    //Turn 2 mono channels into 2 stereo channels
    //Still a bit hacky... cause in the future there can by more than 2 channels and the size might be smaller than 1024
    AudioBuffer ab1 = audio->mBuffers[0];
    AudioBuffer ab2 = audio->mBuffers[1];
    AudioBufferList* abl1 = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], 1024);
    AudioBufferList* abl2 = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], 1024);
    
    abl1->mNumberBuffers = 2;
    abl1->mBuffers[0] = ab1;
    abl1->mBuffers[1] = ab1;
    abl2->mNumberBuffers = 2;
    abl2->mBuffers[0] = ab2;
    abl2->mBuffers[1] = ab2;
    
    //Add the AudioBufferLists to the circular buffers of the output channels
    [THIS->player1 addToBufferAudioBufferList:abl1 frames:frames timestamp:time];
    [THIS->player2 addToBufferAudioBufferList:abl2 frames:frames timestamp:time];
}

-(AEAudioControllerAudioCallback)receiverCallback{
    //Leads to an incompatible pointer type warning
//    return inputCallback;
    //Do type cast to get rid of warning
    return (AEAudioControllerAudioCallback) inputCallback;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)slider1ValueChanged:(id)sender {
    volumes[0] = self.slider1.value;
    [self.audioController setVolume:volumes[0] forChannelGroup:channel1];
}
- (IBAction)slider2ValueChanged:(id)sender {
    volumes[1] = self.slider2.value;
    [self.audioController setVolume:volumes[1] forChannelGroup:channel2];
}
@end
