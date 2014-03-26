//
//  VVAMRCodecWriter.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVAMRCodecWriter.h"

#import "VVAMRCodecEncoder.h"

#define AMR_MAGIC_NUMBER "#!AMR\n"
#define AMR_MAGIC_NUMBER_LENGTH 6

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

@interface VVAMRCodecWriter(){
    FILE * _fd;
    unsigned char * _buffer;
}

@end


@implementation VVAMRCodecWriter

@synthesize encoder = _encoder;

-(void) dealloc{
    
    if(_fd){
        fclose(_fd);
    }
    
    if(_buffer){
        free(_buffer);
    }
    
    [_encoder release];
    
    [super dealloc];
}

-(id) initWithFilePath:(NSString *) filePath encoder:(id<IVVCodecEncoder>) encoder{
    if((self = [super init])){
        
        _fd = fopen([filePath UTF8String], "wb");
        
        if(! _fd){
            [self release];
            return nil;
        }
        
        if(fwrite(AMR_MAGIC_NUMBER, 1, AMR_MAGIC_NUMBER_LENGTH, _fd) != AMR_MAGIC_NUMBER_LENGTH){
            [self release];
            return nil;
        }
        
        _encoder = [encoder retain];
        
        _buffer = malloc([_encoder frameBytes]);
        
    }
    
    return self;
}

-(BOOL) writeBytes:(void *) inBytes{
    
    int length =  [_encoder encode:inBytes to:_buffer];
    
    if(fwrite(_buffer, 1, length, _fd) != length){
        return NO;
    }
    
    return YES;
}

-(void) close{
    
    if(_fd){
        fclose(_fd);
        _fd = nil;
    }
    
}

@end
