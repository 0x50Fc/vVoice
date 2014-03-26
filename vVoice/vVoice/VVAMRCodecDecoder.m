//
//  VVAMRCodecDecoder.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVAMRCodecDecoder.h"

#include "interf_dec.h"

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

@interface VVAMRCodecDecoder(){
    void * _destate;
}

@end

@implementation VVAMRCodecDecoder

-(id) init{
    if((self = [super init])){
        _destate = Decoder_Interface_init();
        if(! _destate){
            [self release];
            return nil;
        }
    }
    return self;
}

-(void) dealloc{
    
    if(_destate){
        Decoder_Interface_exit(_destate);
    }
    
    [super dealloc];
}

-(int) frameSize{
    return PCM_FRAME_SIZE;
}

-(int) frameBytes{
    return PCM_FRAME_SIZE * 2;
}

-(int) samplingRate{
    return 8000;
}

-(BOOL) decode:(void *) inBytes length:(int) length to:(void *) outBytes{
    Decoder_Interface_Decode(_destate, inBytes, outBytes, 0);
    return YES;
}

@end
