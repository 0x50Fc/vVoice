//
//  VVAMRCodecEncoder.h
//  vVoice
//
//  Created by zhang hailong on 14-3-26.
//  Copyright (c) 2014年 hailong.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vVoice/IVVCodecEncoder.h>

typedef enum _VVAMRCodecEncoderMode {
	VVAMRCodecEncoderMode_MR475 = 0,/* 4.75 kbps */
	VVAMRCodecEncoderMode_MR515,    /* 5.15 kbps */
	VVAMRCodecEncoderMode_MR59,     /* 5.90 kbps */
	VVAMRCodecEncoderMode_MR67,     /* 6.70 kbps */
	VVAMRCodecEncoderMode_MR74,     /* 7.40 kbps */
	VVAMRCodecEncoderMode_MR795,    /* 7.95 kbps */
	VVAMRCodecEncoderMode_MR102,    /* 10.2 kbps */
	VVAMRCodecEncoderMode_MR122,    /* 12.2 kbps */
	VVAMRCodecEncoderMode_MRDTX,    /* DTX       */
	VVAMRCodecEncoderMode_N_MODES   /* Not Used  */
} VVAMRCodecEncoderMode;

@interface VVAMRCodecEncoder : NSObject<IVVCodecEncoder>

@property(nonatomic,readonly) VVAMRCodecEncoderMode mode;

-(id) initWithMode:(VVAMRCodecEncoderMode) mode;

@end
