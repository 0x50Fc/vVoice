//
//  VVAMRCodecWriter.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecWriter.h>

@interface VVAMRCodecWriter : NSObject<IVVCodecWriter>

-(id) initWithFilePath:(NSString *) filePath encoder:(id<IVVCodecEncoder>) encoder;

@end
