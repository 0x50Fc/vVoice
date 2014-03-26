//
//  VVAMRCodecReader.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecReader.h>


@interface VVAMRCodecReader : NSObject<IVVCodecReader>

-(id) initWithFilePath:(NSString *) filePath;

@end
