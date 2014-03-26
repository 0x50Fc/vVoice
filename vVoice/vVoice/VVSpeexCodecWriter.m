//
//  VVSpeexCodecWriter.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVSpeexCodecWriter.h"

#include "speex/speex.h"
#include "speex/speex_header.h"
#include "ogg/ogg.h"

@interface VVSpeexCodecWriter(){
    FILE * _file;
    void * _ebuf;
    
}

@end

@implementation VVSpeexCodecWriter

@synthesize closed = _closed;
@synthesize speex = _speex;

-(void) dealloc{
    if(_ebuf){
        free(_ebuf);
    }
    [_speex release];
    [super dealloc];
}

-(id) initWithFilePath:(NSString *) filePath speex:(VVSpeexCodec *) speex{
    if((self = [super init])){
        
        if(speex == nil){
            [self autorelease];
            return nil;
        }
        
        _file = fopen([filePath UTF8String], "wb");
        
        if(_file == nil){
            [self autorelease];
            return nil;
        }
        
        _speex = [speex retain];
        
        const struct SpeexMode * m = & speex_nb_mode;
        
        switch (speex.mode) {
            case VVSpeexCodecNB:
                m = & speex_wb_mode;
                break;
            case VVSpeexCodecUWB:
                m = & speex_uwb_mode;
                break;
            default:
                break;
        }
        
        SpeexHeader header;
        
        speex_init_header(&header, speex.samplingRate, 1, m);
        
        header.vbr = 0;
        header.bitrate = 16;
        header.frame_size = _speex.frameSize;
        header.frames_per_packet = speex.encodeFrameBytes;
        header.reserved1 = speex.quality;
        
        int bytes = 0;
        void * data = speex_header_to_packet(&header, & bytes);
        
        fwrite(data, 1, bytes, _file);
        
        speex_header_free(data);
        
    }
    return self;
}

-(id<IVVCodecEncoder>) encoder{
    return _speex;
}

-(BOOL) writeBytes:(void *)inBytes{
    return [self writeBytes:inBytes echoBytes:nil];
}

-(BOOL) writeBytes:(void *) inBytes echoBytes:(void *) echoBytes{
    
    if(_closed){
        return NO;
    }
    
    int length = [_speex frameBytes];
    
    if(_ebuf == NULL){
        _ebuf = malloc(length);
    }
    
    memset(_ebuf, 0, length);
    
    if((length = [_speex encode:inBytes to:_ebuf echoBytes:echoBytes]) > 0){
        
        fwrite(_ebuf, 1, _speex.encodeFrameBytes, _file);
        
        return YES;
    }
    
    return NO;
}

-(void) close{
    
    if(!_closed){
        
        if(_file){
            
            fclose(_file);
            _file = NULL;
        }

    }
    
}

@end
