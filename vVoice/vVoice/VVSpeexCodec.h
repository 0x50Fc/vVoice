//
//  VVSpeexCodec.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodec.h>
#import <vVoice/IVVCodecEncoder.h>
#import <vVoice/IVVCodecDecoder.h>

typedef enum _VVSpeexCodecMode {
    VVSpeexCodecNB,VVSpeexCodecWB,VVSpeexCodecUWB
} VVSpeexCodecMode;

@interface VVSpeexCodec : NSObject<IVVCodec,IVVCodecEncoder,IVVCodecDecoder>

@property(nonatomic, readonly) VVSpeexCodecMode mode;
@property(nonatomic,assign) int quality;  // 1~10 default 8

-(id) initWithMode:(VVSpeexCodecMode) mode;

-(int) encode:(void *)inBytes to:(void *)outBytes echoBytes:(void *) echoBytes;

+(NSInteger) encodeFrameBytesWithQuality:(NSInteger) quality;

-(void) setSamplingRate:(int) samplingRate;

@end
