//
//  VVPlayer.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecReader.h>


@interface VVPlayer : NSOperation

@property(nonatomic,assign) id delegate;
@property(nonatomic,readonly) SInt16 * frameBytes;
@property(nonatomic,readonly) UInt32 frameSize;
@property(nonatomic,readonly) NSTimeInterval duration;
@property(nonatomic,readonly) id<IVVCodecReader> reader;

-(id) initWithReader:(id<IVVCodecReader>) reader;

@end

@protocol VVPlayerDelegate

@optional

-(void) VVPlayerDidFinished:(VVPlayer *) player;

@end
