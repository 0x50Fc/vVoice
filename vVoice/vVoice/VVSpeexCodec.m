//
//  VVSpeexCodec.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVSpeexCodec.h"

#include "speex/speex.h"
#include "speex/speex_preprocess.h"
#include "speex/speex_echo.h"

static int VVSpeexBitSizes[] = {10,15,20,20,28,28,38,38,46,46};

@interface VVSpeexCodec(){
    void * _encodeState;
	void * _decodeState;
	SpeexPreprocessState * _preprocessState;
	SpeexEchoState * _echoState;
	SpeexBits _bits;
    spx_int16_t * _ebuf;
}

@end

@implementation VVSpeexCodec

@synthesize frameSize = _frameSize;
@synthesize samplingRate = _samplingRate;
@synthesize quality = _quality;
@synthesize frameBytes = _frameBytes;
@synthesize encodeFrameBytes = _encodeFrameBytes;

-(id) initWithMode:(VVSpeexCodecMode) mode{
    if((self = [super init])){
        
        _quality = 8;
        _encodeFrameBytes = VVSpeexBitSizes[_quality - 1];
        _mode = mode;
        
        switch (mode) {
            case VVSpeexCodecNB:
                _encodeState = speex_encoder_init(& speex_nb_mode);
                _decodeState = speex_decoder_init(& speex_nb_mode);
                break;
            case VVSpeexCodecWB:
                _encodeState = speex_encoder_init(& speex_wb_mode);
                _decodeState = speex_decoder_init(& speex_wb_mode);
                break;
            case VVSpeexCodecUWB:
                _encodeState = speex_encoder_init(& speex_uwb_mode);
                _decodeState = speex_decoder_init(& speex_uwb_mode);
                break;
            default:
                [self release];
                return nil;
                break;
        }
        
        speex_bits_init(& _bits);
        
        
        int b = 1;
        
        speex_encoder_ctl(_encodeState,SPEEX_GET_FRAME_SIZE,&_frameSize);
        speex_encoder_ctl(_encodeState,SPEEX_SET_QUALITY,&_quality);
        speex_encoder_ctl(_encodeState,SPEEX_GET_SAMPLING_RATE,&_samplingRate);
        speex_encoder_ctl(_encodeState,SPEEX_SET_DTX,&b);
        speex_encoder_ctl(_encodeState,SPEEX_SET_VAD,&b);
        
        _preprocessState = speex_preprocess_state_init(_frameSize,_samplingRate);
        
        speex_preprocess_ctl(_preprocessState, SPEEX_PREPROCESS_SET_DENOISE, &b);
        
        _echoState = speex_echo_state_init(_frameSize, 100 );
        
        _frameBytes = _frameSize * sizeof(spx_int16_t);
        
    }
    return self;
}

-(void) dealloc{
    
    speex_bits_destroy(& _bits);
    
    if(_encodeState){
        speex_encoder_destroy(_encodeState);
    }
    
    if(_decodeState){
        speex_decoder_destroy(_decodeState);
    }
    
    if(_preprocessState){
        speex_preprocess_state_destroy(_preprocessState);
    }
    
    if(_echoState){
        speex_echo_state_destroy(_echoState);
    }
    
    if(_ebuf){
        free(_ebuf);
    }
    
    [super dealloc];
}

-(int) encode:(void *)inBytes to:(void *)outBytes{
    return [self encode:inBytes to:outBytes echoBytes:nil];
}

-(int) encode:(void *)inBytes to:(void *)outBytes echoBytes:(void *) echoBytes{
  
    spx_int16_t * enc = (spx_int16_t *) inBytes;
    
    if(echoBytes){
        
        if(_ebuf == NULL){
            _ebuf = (spx_int16_t *) malloc(_frameBytes);
        }
        
        speex_echo_state_reset(_echoState);
        speex_echo_cancellation(_echoState, enc, echoBytes, _ebuf);
        
        enc = _ebuf;
    }
    
    if(speex_preprocess_run(_preprocessState, enc))
    {
        speex_bits_reset(&_bits);
        speex_encode_int(_encodeState, enc, &_bits);
        return speex_bits_write(&_bits, outBytes, _frameBytes);
    }
    
    return 0;
}

-(BOOL) decode:(void *)inBytes length:(int)length to:(void *)outBytes{
    
    int rs = 0;
    
    speex_bits_reset(&_bits);
    speex_bits_read_from(&_bits, inBytes, length);
    rs = speex_decode_int(_decodeState, &_bits, outBytes);
    
    return rs ==0 ? _frameBytes : 0;
    
}


-(void) setQuality:(NSInteger)quality{
    _quality = quality;
    if(_quality < 1){
        _quality = 1;
    }
    if(_quality > 10){
        _quality = 10;
    }
    _encodeFrameBytes = VVSpeexBitSizes[_quality - 1];
    speex_encoder_ctl(_encodeState,SPEEX_SET_QUALITY,&_samplingRate);
}

+(NSInteger) encodeFrameBytesWithQuality:(NSInteger) quality{
    if(quality < 1){
        quality = 1;
    }
    if(quality > 10){
        quality = 10;
    }
    return VVSpeexBitSizes[quality -1];
}

@end
