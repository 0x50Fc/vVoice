//
//  VVRecoder.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecWriter.h>


@interface VVRecoder : NSOperation

@property(nonatomic,assign) id delegate;

@property(nonatomic,readonly) id<IVVCodecWriter> writer;
@property(nonatomic,readonly) NSTimeInterval duration;
@property(nonatomic,readonly) SInt16 * frameBytes;
@property(nonatomic,readonly) UInt32 frameSize;

-(id) initWithWriter:(id<IVVCodecWriter>) writer;

-(void) stop;

-(void) resume;

-(void) pause;

@end

@protocol VVRecoderDelegate

@optional

-(void) VVRecoderDidStarted:(VVRecoder *) recorder;

-(void) VVRecoderDidStoped:(VVRecoder *) recorder;

@end
