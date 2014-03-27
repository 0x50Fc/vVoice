//
//  VVSpeexCodecReader.h
//  vVoice
//
//  Created by zhang hailong on 14-3-27.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecReader.h>

#import <vVoice/VVSpeexCodec.h>

@interface VVSpeexCodecReader : NSObject<IVVCodecReader>

@property(nonatomic,readonly) VVSpeexCodec * speex;
@property(nonatomic,readonly, getter = isClosed) BOOL closed;

-(id) initWithFilePath:(NSString *) filePath;

@end
