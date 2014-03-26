//
//  IVVCodecEncoder.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodec.h>

@protocol IVVCodecEncoder <IVVCodec>

@property(nonatomic,readonly) int encodeFrameBytes; // 最大编码帧大小

-(int) encode:(void *) inBytes to:(void *) outBytes;

@end
