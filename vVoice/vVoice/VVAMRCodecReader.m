//
//  VVAMRCodecReader.m
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import "VVAMRCodecReader.h"

#import "VVAMRCodecDecoder.h"

#define AMR_MAGIC_NUMBER "#!AMR\n"
#define AMR_MAGIC_NUMBER_LENGTH 6

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

@interface VVAMRCodecReader() {
    FILE * _fd;
    unsigned char _stdFrameHeader;
    int _stdFrameSize;
}

@end

@implementation VVAMRCodecReader

@synthesize decoder = _decoder;

-(void) dealloc{
    
    if(_fd){
        fclose(_fd);
    }
    
    [_decoder release];
    
    [super dealloc];
}

-(id) initWithFilePath:(NSString *) filePath{

    if((self = [super init])){
        
        _fd = fopen([filePath UTF8String], "rb");
        
        if(!_fd){
            [self release];
            return nil;
        }
        
        char magic[AMR_MAGIC_NUMBER_LENGTH + 1];

        if(AMR_MAGIC_NUMBER_LENGTH != fread(magic, 1, AMR_MAGIC_NUMBER_LENGTH, _fd)){
            [self release];
            return nil;
        }
        
        if(strncmp(magic, AMR_MAGIC_NUMBER, sizeof(magic)) != 0){
            [self release];
            return nil;
        }
        
        _decoder = [[VVAMRCodecDecoder alloc] init];

    }
    
    return self;
}

static const int myround(const double x)
{
	return((int)(x+0.5));
}

static int amrEncodeMode[] = {4750, 5150, 5900, 6700, 7400, 7950, 10200, 12200}; // amr 编码方式

static int caclAMRFrameSize(unsigned char frameHeader)
{
	int mode;
	int temp1 = 0;
	int temp2 = 0;
	int frameSize;
    
	temp1 = frameHeader;
    
	// 编码方式编号 = 帧头的3-6位
	temp1 &= 0x78; // 0111-1000
	temp1 >>= 3;
    
	mode = amrEncodeMode[temp1];
    
	// 计算amr音频数据帧大小
	// 原理: amr 一帧对应20ms，那么一秒有50帧的音频数据
	temp2 = myround((double)(((double)mode / (double)AMR_FRAME_COUNT_PER_SECOND) / (double)8));
    
	frameSize = myround((double)temp2 + 0.5);
	return frameSize;
}

-(BOOL) readToBytes:(void *) outBytes{
    
    unsigned char * up = (unsigned char *) outBytes;
    
    int frameBytes = [_decoder frameBytes];
    
    memset(outBytes, 0, frameBytes);
    
    if(_stdFrameHeader == 0){
        
        if(sizeof(unsigned char) != fread(& _stdFrameHeader, 1, sizeof(unsigned char), _fd)){
            return NO;
        }
        
        _stdFrameSize = caclAMRFrameSize(_stdFrameHeader);
        
        if(_stdFrameSize <= 0){
            return NO;
        }
        
        * up = _stdFrameHeader;
        
        if(_stdFrameSize -1 != fread(up + 1, 1, (_stdFrameSize - 1), _fd)){
            return NO;
        }
        
        return YES;
    }
    else {
        
        unsigned char frameHeader; // 帧头
        
        // 读帧头
        // 如果是坏帧(不是标准帧头)，则继续读下一个字节，直到读到标准帧头
        while(1)
        {
            if(1 == fread(&frameHeader, 1, sizeof(unsigned char), _fd)){
                if(frameHeader == _stdFrameSize){
                    break;
                }
            }
            else{
                return NO;
            }
        }
        
        * up = frameHeader;
        
        if(_stdFrameSize -1 != fread(up + 1, 1, (_stdFrameSize - 1), _fd)){
            return NO;
        }
        return YES;
    }
}

-(void) close{
    if(_fd){
        fclose(_fd);
        _fd = nil;
    }
}

@end
