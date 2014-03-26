//
//  VVSpeexCodecWriter.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecWriter.h>

#import <vVoice/VVSpeexCodec.h>

@interface VVSpeexCodecWriter : NSObject<IVVCodecWriter>

@property(nonatomic,readonly) VVSpeexCodec * speex;
@property(nonatomic,readonly, getter = isClosed) BOOL closed;

-(id) initWithFilePath:(NSString *) filePath speex:(VVSpeexCodec *) speex;

-(BOOL) writeBytes:(void *) inBytes echoBytes:(void *) echoBytes;

@end
