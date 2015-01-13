//
//  ViewController.m
//  taaeTest2
//
//  Created by Sander on 12/30/14.
//  Copyright (c) 2014 Sander. All rights reserved.
//

#import "ViewController.h"

//@interface MyAudioReceiver : NSObject <AEAudioReceiver> {
//    
//}
//
//@property (nonatomic, assign) TPCircularBuffer cb;
//- (void)blaat: (const AudioTimeStamp)*time;
//@end
//@implementation MyAudioReceiver
//static void receiverCallback(__unsafe_unretained MyAudioReceiver *THIS,
//                             __unsafe_unretained AEAudioController *audioController,
//                             void                     *source,
//                             const AudioTimeStamp     *time,
//                             UInt32                    frames,
//                             AudioBufferList          *audio) {
//    
//    // Do something with 'audio'
//    NSLog(@"Blaat");
//    
//    
//}
//-(AEAudioControllerAudioCallback)receiverCallback {
//    return receiverCallback;
//}
//
//public void addToBuffer(   const AudioTimeStamp     *time,
//                    UInt32                    frames,
//                    AudioBufferList          *audio) {
//    TPCircularBufferCopyAudioBufferList(&_cb, audio, time, kTPCircularBufferCopyAll, NULL);
//}
//
//-(void)blaat:(AudioTimeStamp)*time {
//    
//}

//@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
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

    
    
    volumes = (float *)malloc(sizeof(float) * 2);
    volumes[0] = self.slider1.value;
    
//    [input1 initAudioReceiver];
//    [input2 initAudioReceiver];
//    
//    TPCircularBufferInit(&_cb, 16384);
    
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled: YES];
    _audioController.preferredBufferDuration = 0.005;
    
    NSError *error = [NSError alloc];
    if(![self.audioController start:&error]){
        NSLog(@"Error starting AudioController: %@", error.localizedDescription);
    }
    
    
    
    
//    _playthrough = [[AEPlaythroughChannel alloc] initWithAudioController: _audioController];
//    [self.audioController addInputReceiver:_playthrough];
//    [self.audioController addChannels:@[_playthrough]];
//
    
    //id<AEAudioReceiver> input1 = [[MyAudioReceiver alloc] init];
    //    MyAudioReceiver *input1 = [[MyAudioReceiver alloc] init];
    //    MyAudioReceiver *input2 = [[MyAudioReceiver alloc] init];
    
    
    player1 = [[MyAudioPlayer alloc] init];
    player2 = [[MyAudioPlayer alloc] init];

    channel1 = [self.audioController createChannelGroup];
    channel2 = [self.audioController createChannelGroup];
    
    [self.audioController addInputReceiver:self];
//    NSArray *a = [[NSArray alloc] initWithObjects:self, nil];
//    [self.audioController addChannels:a];
//    NSArray *players = [[NSArray alloc] initWithObjects:player1, player2, nil];
//    [self.audioController addChannels:players];
    
    [self.audioController addChannels:[[NSArray alloc] initWithObjects:player1, nil] toChannelGroup:channel1];
    [self.audioController addChannels:[[NSArray alloc] initWithObjects:player2, nil] toChannelGroup:channel2];
    
    [self.audioController setVolume:volumes[0] forChannelGroup:channel1];
    
    
//    AudioStreamBasicDescription asbd = [self.audioController inputAudioDescription];
//    [self.audioController set
    
}

static void inputCallback(__unsafe_unretained ViewController *THIS,
                          __unsafe_unretained AEAudioController *audioController,
                          void                     *source,
                          const AudioTimeStamp     *time,
                          UInt32                    frames,
                          AudioBufferList          *audio) {
    
    AudioBuffer ab1 = audio->mBuffers[0];
    AudioBuffer ab2 = audio->mBuffers[1];
    AudioBufferList* abl1 = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], 1024);
    AudioBufferList* abl2 = AEAllocateAndInitAudioBufferList([AEAudioController nonInterleavedFloatStereoAudioDescription], 1024);
    
    float volume = 0.5f;
    
    abl1->mNumberBuffers = 2;
    abl1->mBuffers[0] = ab1;
    abl1->mBuffers[1] = ab1;
    abl2->mNumberBuffers = 2;
    abl2->mBuffers[0] = ab2;
    abl2->mBuffers[1] = ab2;
//
//    float desiredGain = 1.06f; // or whatever linear gain you'd like
//    AudioBufferList *ioData = abl; // audio from somewhere
//    for(UInt32 bufferIndex = 0; bufferIndex < ioData->mNumberBuffers; bufferIndex++) {
//        if(bufferIndex == 0){
//            desiredGain = 0.0f;
//        } else {
//            desiredGain = 0.0f;
//        }
//        int *rawBuffer = (int *)ioData->mBuffers[bufferIndex].mData;
//        vDSP_Length frameCount = ioData->mBuffers[bufferIndex].mDataByteSize / sizeof(int); // if you don't have it already
//        desiredGain = 100;
//        for(int i = 0; i< frameCount; i++){
//            rawBuffer[i] -= desiredGain;
//            //vDSP_vsmul(&rawBuffer[i], 1, &desiredGain, &rawBuffer[i], 1, 1);
//        }
//        //vDSP_vsmul(rawBuffer, 1, &desiredGain, rawBuffer, 1, frameCount);
//    }
//    
    
    
    //if ( THIS->_audiobusConnectedToSelf ) return;
//    TPCircularBufferCopyAudioBufferList(&THIS->_cb, audio, time, kTPCircularBufferCopyAll, NULL);
//    TPCircularBufferCopyAudioBufferList(&THIS->_cb, ioData, time, kTPCircularBufferCopyAll, NULL);
    
    [THIS->player1 addToBufferAudioBufferList:abl1 frames:frames timestamp:time];
    [THIS->player2 addToBufferAudioBufferList:abl2 frames:frames timestamp:time];
    
}

-(AEAudioControllerAudioCallback)receiverCallback{
    return inputCallback;
}

static OSStatus renderCallback(__unsafe_unretained ViewController *THIS,
                               __unsafe_unretained AEAudioController *audioController,
                               const AudioTimeStamp     *time,
                               UInt32                    frames,
                               AudioBufferList          *audio) {
    NSLog(@"Outpuuut");
    
    while ( 1 ) {
        // Discard any buffers with an incompatible format, in the event of a format change
        AudioBufferList *nextBuffer = TPCircularBufferNextBufferList(&THIS->_cb, NULL);
        if ( !nextBuffer ) break;
        if ( nextBuffer->mNumberBuffers == audio->mNumberBuffers ) break;
        TPCircularBufferConsumeNextBufferList(&THIS->_cb);
    }
    
    UInt32 fillCount = TPCircularBufferPeek(&THIS->_cb, NULL, AEAudioControllerAudioDescription(audioController));
    if ( fillCount > frames ) {
        UInt32 skip = fillCount - frames;
        TPCircularBufferDequeueBufferListFrames(&THIS->_cb,
                                                &skip,
                                                NULL,
                                                NULL,
                                                AEAudioControllerAudioDescription(audioController));
    }
    
    TPCircularBufferDequeueBufferListFrames(&THIS->_cb,
                                            &frames,
                                            audio,
                                            NULL,
                                            AEAudioControllerAudioDescription(audioController));
    
    return noErr;
}

-(AEAudioControllerRenderCallback)renderCallback{
    return renderCallback;
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
