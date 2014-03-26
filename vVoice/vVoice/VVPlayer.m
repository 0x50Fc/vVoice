//
//  VVPlayer.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVPlayer.h"

#import <AudioToolbox/AudioToolbox.h>

#define AUDIO_RECORD_BUFFER_SIZE		4

@interface VVPlayer(){
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[AUDIO_RECORD_BUFFER_SIZE];
    AudioStreamBasicDescription format;
    int _bufferSize;
    BOOL _finished;
    BOOL _executing;
}

@property(nonatomic,assign) int bufferSize;
@property(nonatomic,assign) NSTimeInterval beginTimeInterval;

-(void) setFinished:(BOOL) finished;

-(void) setFrameBytes:(SInt16 *) bytes;

@end

static void VVPlayer_AudioQueueOutputCallback(
                                                  void *                  inUserData,
                                                  AudioQueueRef           inAQ,
                                                  AudioQueueBufferRef     inBuffer){
	
    VVPlayer * player = (VVPlayer *) inUserData;
    
    inBuffer->mAudioDataByteSize = player.bufferSize;
    
    if([player.reader readToBytes:inBuffer->mAudioData]){
        [player setFrameBytes:inBuffer->mAudioData];
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
    else{
        [player setFinished:YES];
    }
    
}

@implementation VVPlayer


@synthesize delegate = _delegate;
@synthesize frameBytes = _frameBytes;
@synthesize frameSize = _frameSize;
@synthesize beginTimeInterval = _beginTimeInterval;

-(void) dealloc{
    [_reader release];
    if(_frameBytes){
        free(_frameBytes);
    }
    [super dealloc];
}

-(BOOL) isReady{
    return _reader != nil;
}

-(BOOL) isConcurrent{
    return YES;
}

-(BOOL) isExecuting{
    return _executing;
}

-(BOOL) isFinished{
    return _finished;
}

-(void) cancel{
    [super cancel];
    _finished = YES;
}

-(void) main{
    
    _executing = YES;
    
    @autoreleasepool {
        
        NSRunLoop * runloop = [NSRunLoop currentRunLoop];
        
        _bufferSize = [[_reader decoder] frameBytes];
        _frameSize = [[_reader decoder] frameSize];
        
        if(_frameBytes == NULL){
            _frameBytes = malloc(_bufferSize);
        }
        else{
            _frameBytes = realloc(_frameBytes, _bufferSize);
        }
        
        memset(_frameBytes, 0, _bufferSize);
        
        format.mFormatID = kAudioFormatLinearPCM;
        format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger;
        format.mChannelsPerFrame = 1;
        format.mBitsPerChannel = 16;
        format.mFramesPerPacket = 1;
        format.mBytesPerPacket =  2;
        format.mBytesPerFrame = 2;
        format.mSampleRate = [[_reader decoder] samplingRate];
        
        _beginTimeInterval = CFAbsoluteTimeGetCurrent();
        
        OSStatus status;
        
        status = AudioQueueNewOutput(&format, VVPlayer_AudioQueueOutputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_queue);
        
        for(int i=0;i<AUDIO_RECORD_BUFFER_SIZE;i++){
            
            AudioQueueAllocateBuffer(_queue,_bufferSize,&_buffers[i]);
            
        }
        
        for(int i=0;i<AUDIO_RECORD_BUFFER_SIZE;i++){
            
            if([_reader readToBytes:_buffers[i]->mAudioData]){
                _buffers[i]->mAudioDataByteSize = _bufferSize;
                AudioQueueEnqueueBuffer(_queue, _buffers[i], 0, NULL);
            }
            else{
                break;
            }
            
        }
        
        status = AudioQueuePrime(_queue, 0, NULL);
        
        AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, 1.0);
        
        status = AudioQueueStart(_queue, NULL);
        
        
        while(![self isCancelled] && !_finished){
            @autoreleasepool {
                [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
            }
        }
        
        AudioQueueStop(_queue, YES);
		
        for(int i=0;i<AUDIO_RECORD_BUFFER_SIZE;i++){
            
            AudioQueueFreeBuffer(_queue,_buffers[i]);
            
        }
        
		
		AudioQueueDispose(_queue, YES);
        
        
        _queue = NULL;
        
        if([_delegate respondsToSelector:@selector(VVPlayerDidFinished:)] && ![self isCancelled]){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if([_delegate respondsToSelector:@selector(VVPlayerDidFinished:)]){
                    [_delegate VVPlayerDidFinished: self];
                }
                
            });
        }
        
    }
    
    _executing = NO;
}

-(id) initWithReader:(id<IVVCodecReader>) reader{
    if((self = [super init])){
        _reader = [reader retain];
        if(_reader == nil){
            [self autorelease];
            return nil;
        }
    }
    return self;
}

-(void) setFinished:(BOOL) finished{
    _finished = finished;
}

-(void) setFrameBytes:(SInt16 *) bytes{
    if(_frameBytes){
        memcpy(_frameBytes, bytes, _frameSize * sizeof(SInt16));
    }
}


-(NSTimeInterval) duration{
    if(_beginTimeInterval == 0.0){
        return 0.0;
    }
    
    return CFAbsoluteTimeGetCurrent() - _beginTimeInterval;
}


@end
