//
//  VVSpeexCodecReader.m
//  vVoice
//
//  Created by zhang hailong on 14-3-27.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVSpeexCodecReader.h"


#include "speex/speex.h"
#include "speex/speex_header.h"
#include "ogg/ogg.h"


@interface VVSpeexCodecReader(){
    FILE * _file;
    VVSpeexCodec * _speex;
    char * _dbuf;
    int _decodeFrameBytes;
}

@end


@implementation VVSpeexCodecReader

@synthesize speex = _speex;
@synthesize closed = _closed;

-(id) initWithFilePath:(NSString *) filePath{
    if((self = [super init])){
        
        _file = fopen([filePath UTF8String], "rb");
        
        if(_file == nil){
            [self autorelease];
            return nil;
        }
        
        char data[sizeof(SpeexHeader)];
        
        if(sizeof(data) != fread(data, 1, sizeof(data), _file)){
            [self autorelease];
            return nil;
        }
        
        SpeexHeader * header = speex_packet_to_header(data, sizeof(data));
        
        if(!header){
            [self autorelease];
            return nil;
        }
        
        _speex = [[VVSpeexCodec alloc] initWithMode:header->mode];
        
        [_speex setSamplingRate:header->rate];
        
        if(header->reserved1){
            [_speex setQuality:header->reserved1];
        }
        
        _decodeFrameBytes = header->frames_per_packet;
        
        speex_header_free(header);
        
        if(_speex == nil){
            [self autorelease];
            return nil;
        }
    }
    return self;
}

-(id<IVVCodecDecoder>) decoder{
    return _speex;
}

-(void) dealloc{
    
    [self close];
    
    [_speex release];
    
    if(_dbuf){
        free(_dbuf);
    }
    
    [super dealloc];
}

-(BOOL) readToBytes:(void *) outBytes{
    
    if(_closed ){
        return NO;
    }
    
    if(feof(_file)){
        return NO;
    }
    
    if(_dbuf == NULL){
        _dbuf = malloc(_speex.frameBytes);
    }
    
    if(_decodeFrameBytes == 0){
        
        unsigned short l = 0;
        
        if(fread(&l, 1, sizeof(l), _file) != sizeof(l)){
            return NO;
        }
        
        l = ntohs(l);
        
        if(l >0){
            
            if(l != fread(_dbuf, 1, l, _file)){
                return NO;
            }
            
            return [_speex decode:_dbuf length:l to:outBytes];
        }
        
    }
    else{
        
        if(_decodeFrameBytes != fread(_dbuf, 1, _decodeFrameBytes, _file)){
            return NO;
        }
        
        return [_speex decode:_dbuf length:_decodeFrameBytes to:outBytes];
        
    }
    
    return YES;
    
}

-(void) close{
    
    if(!_closed){
        
        _closed = YES;
        
        if(_file){
            fclose(_file);
            _file = NULL;
        }
        

    }

}

@end
