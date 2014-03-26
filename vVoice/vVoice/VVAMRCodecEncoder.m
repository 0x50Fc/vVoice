//
//  VVAMRCodecEncoder.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVAMRCodecEncoder.h"

#include "interf_enc.h"

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

@interface VVAMRCodecEncoder(){
    void * _enstate;
}

@end

@implementation VVAMRCodecEncoder

-(id) initWithMode:(VVAMRCodecEncoderMode) mode{
    
    if((self = [super init])){
        _mode = mode;
        _enstate = Encoder_Interface_init(0);
        
        if(_enstate == nil){
            [self release];
            return nil;
        }
    }
    
    return self;
}

-(void) dealloc{
    
    if(_enstate){
        Encoder_Interface_exit(_enstate);
    }
    
    [super dealloc];
}

-(int) frameSize{
    return PCM_FRAME_SIZE;
}

-(int) frameBytes{
    return PCM_FRAME_SIZE * 2;
}

-(int) encodeFrameBytes{
    return MAX_AMR_FRAME_SIZE;
}

-(int) samplingRate{
    return 8000;
}

-(int) encode:(void *) inBytes to:(void *) outBytes{
    return Encoder_Interface_Encode(_enstate, (enum Mode) _mode, inBytes, outBytes, 0);
}

@end
