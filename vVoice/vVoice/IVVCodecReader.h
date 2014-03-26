//
//  IVVCodecReader.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecDecoder.h>

@protocol IVVCodecReader <NSObject>

@property(nonatomic,readonly) id<IVVCodecDecoder> decoder;

-(BOOL) readToBytes:(void *) outBytes;

-(void) close;

@end
