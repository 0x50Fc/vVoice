//
//  VVRecoder.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVRecoder.h"
#import <AudioToolbox/AudioToolbox.h>

#define AUDIO_RECORD_BUFFER_SIZE		4

@interface VVRecoder(){
    
    AudioQueueRef _queue;
    AudioQueueBufferRef _buffers[AUDIO_RECORD_BUFFER_SIZE];
    AudioStreamBasicDescription format;
    int _bufferSize;
    
    BOOL _finished;
    BOOL _executing;
    BOOL _stoping;
    
    NSTimeInterval _beginTimeInterval;
    NSTimeInterval _pauseTimeInterval;
    
}

@property(nonatomic,assign) NSTimeInterval frameDuration;

-(void) setFinished:(BOOL) finished;

-(BOOL) isStoping;

-(void) setFrameBytes:(SInt16 *) bytes;

@end

static void VVRecoder_AudioQueueInputCallback(
                                                   void *                          inUserData,
                                                   AudioQueueRef                   inAQ,
                                                   AudioQueueBufferRef             inBuffer,
                                                   const AudioTimeStamp *          inStartTime,
                                                   UInt32                          inNumberPacketDescriptions,
                                                   const AudioStreamPacketDescription *inPacketDescs){
	
    VVRecoder * recorder = (VVRecoder *) inUserData;
    
    [recorder setFrameBytes:inBuffer->mAudioData];
    
    id<IVVCodecWriter> writer = [recorder writer];
    
    [writer writeBytes:inBuffer->mAudioData];
    
    if(![recorder isStoping]){
        inBuffer->mAudioDataByteSize = 0;
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
    
}

static void VVRecoder_AudioQueuePropertyListener(
                                                      void *                  inUserData,
                                                      AudioQueueRef           inAQ,
                                                      AudioQueuePropertyID    inID){
    
    VVRecoder * recorder = (VVRecoder *) inUserData;
    
    UInt32 f = 0;
    
    AudioQueueGetProperty(inAQ, inID, &f, NULL);
    
    if(f == 0){
        [recorder setFinished:YES];
        
    }
}



@implementation VVRecoder


@synthesize writer = _writer;
@synthesize delegate = _delegate;
@synthesize duration = _duration;
@synthesize frameDuration = _frameDuration;
@synthesize frameBytes = _frameBytes;
@synthesize frameSize = _frameSize;

-(void) dealloc{
    [_writer close];
    [_writer release];
    if(_frameBytes){
        free(_frameBytes);
    }
    [super dealloc];
}

-(id) initWithWriter:(id<IVVCodecWriter>)writer{
    
    if((self = [super init])){
        _writer = [writer retain];
        if(_writer == nil){
            [self autorelease];
            return nil;
        }
    }
    return self;
}



-(BOOL) isReady{
    return _writer != nil;
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
    if(_queue){
        AudioQueueStop(_queue, YES);
    }
    _finished = YES;
}

-(void) stop{
    if(!_stoping){
        
        if(_queue){
            
            AudioQueueStop(_queue, NO);
            
            UInt32 f = 0;
            
            AudioQueueGetProperty(_queue, kAudioQueueProperty_IsRunning, &f, NULL);
            
            if(f == 0){
                [self setFinished:YES];
            }
        }
        
        _stoping = YES;
    }
}

-(void) main{
    
    _executing = YES;
    
    @autoreleasepool {
        
        _beginTimeInterval = CFAbsoluteTimeGetCurrent();
        
        if(_stoping){
            
            _executing = NO;
            _finished = YES;
            
            if([_delegate respondsToSelector:@selector(VVRecoderDidStoped:)]){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_delegate VVRecoderDidStoped:self];
                    
                });
                
            }
            
            return;
        }
        
        NSRunLoop * runloop = [NSRunLoop currentRunLoop];
        
        _bufferSize = [[_writer encoder] frameBytes];
        _frameSize = [[_writer encoder] frameSize];
        
        if(_frameBytes == NULL){
            _frameBytes = malloc(_bufferSize);
        }
        else{
            _frameBytes = realloc(_frameBytes, _bufferSize);
        }
        
        memset(_frameBytes, 0, _bufferSize);
        
        format.mFormatID = kAudioFormatLinearPCM;
        format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        format.mChannelsPerFrame = 1;
        format.mBitsPerChannel = 16;
        format.mFramesPerPacket = 1;
        format.mBytesPerPacket =  2;
        format.mBytesPerFrame = 2;
        format.mSampleRate = [[_writer encoder] samplingRate];
        
        _frameDuration = (NSTimeInterval) _frameSize / format.mSampleRate;
        
        OSStatus status;
        
        status = AudioQueueNewInput(&format, VVRecoder_AudioQueueInputCallback, self, [runloop getCFRunLoop], kCFRunLoopCommonModes, 0, &_queue);
        
        for(int i=0;i<AUDIO_RECORD_BUFFER_SIZE;i++){
            status = AudioQueueAllocateBuffer(_queue,_bufferSize,&_buffers[i]);
            status = AudioQueueEnqueueBuffer(_queue, _buffers[i], 0, NULL);
        }
        
        AudioQueueFlush(_queue);
        
        AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, 1.0);
        
        status = AudioQueueStart(_queue, NULL);
        
        AudioQueueAddPropertyListener(_queue, kAudioQueueProperty_IsRunning, VVRecoder_AudioQueuePropertyListener, self);
        
        if([_delegate respondsToSelector:@selector(VVRecoderDidStarted:)]){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_delegate VVRecoderDidStarted:self];
                
            });
        }
        
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
        
        [_writer close];
        
        
        if([_delegate respondsToSelector:@selector(VVRecoderDidStoped:)]){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_delegate VVRecoderDidStoped:self];
                
            });
            
        }
        
    }
    
    _executing = NO;
}

-(void) setFinished:(BOOL) finished{
    _finished = finished;
    _duration = CFAbsoluteTimeGetCurrent() - _beginTimeInterval;
}

-(BOOL) isStoping{
    return _stoping;
}

-(NSTimeInterval) duration{
    if(_beginTimeInterval == 0){
        return 0;
    }
    if(_finished){
        return _duration;
    }
    if(_pauseTimeInterval){
        return _pauseTimeInterval - _beginTimeInterval;
    }
    return CFAbsoluteTimeGetCurrent() - _beginTimeInterval;
}

-(void) setFrameBytes:(SInt16 *) bytes{
    if(_frameBytes){
        memcpy(_frameBytes, bytes, _frameSize * sizeof(SInt16));
    }
}

-(void) resume{
    if(_queue && _pauseTimeInterval != 0.0){
        _beginTimeInterval += CFAbsoluteTimeGetCurrent() - _pauseTimeInterval;
        _pauseTimeInterval = 0.0;
        AudioQueueStart(_queue, NULL);
    }
}

-(void) pause{
    if(_queue && _pauseTimeInterval == 0.0){
        _pauseTimeInterval = CFAbsoluteTimeGetCurrent();
        AudioQueuePause(_queue);
    }
}


@end
