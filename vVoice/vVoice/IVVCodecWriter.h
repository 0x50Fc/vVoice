//
//  IVVCodecWriter.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecEncoder.h>

@protocol IVVCodecWriter <NSObject>

@property(nonatomic,readonly) id<IVVCodecEncoder> encoder;

-(BOOL) writeBytes:(void *) inBytes;

-(void) close;

@end
