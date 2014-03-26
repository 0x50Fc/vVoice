//
//  IVVCodec.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IVVCodec <NSObject>

@property(nonatomic,readonly) int frameSize;    // 帧大小

@property(nonatomic,readonly) int frameBytes;   // 帧字节

@property(nonatomic,readonly) int samplingRate; // 码率

@end
