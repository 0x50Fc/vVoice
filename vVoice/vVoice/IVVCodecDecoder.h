//
//  IVVCodecDecoder.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodec.h>

@protocol IVVCodecDecoder <IVVCodec>

-(BOOL) decode:(void *) inBytes length:(int) length to:(void *) outBytes;

@end
