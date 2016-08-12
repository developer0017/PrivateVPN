//
//  VCenterSecureTextFieldCell.m
//  PrivateVPN
//
//  Created by Star Developer on 3/11/16.
//  Copyright © 2016 Oscar. All rights reserved.
//

#import "VCenterSecureTextFieldCell.h"

@implementation VCenterSecureTextFieldCell
- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame {
    // super would normally draw text at the top of the cell
    //NSInteger offset = floor((NSHeight(frame) - ([[self font] ascender] - [[self font] descender])) / 2);
    return NSInsetRect(frame, 0.0, 3.0);
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView
               editor:(NSText *)editor delegate:(id)delegate event:(NSEvent *)event {
    [super editWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
                  inView:controlView editor:editor delegate:delegate event:event];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView
                 editor:(NSText *)editor delegate:(id)delegate
                  start:(NSInteger)start length:(NSInteger)length {
    
    [super selectWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
                    inView:controlView editor:editor delegate:delegate
                     start:start length:length];
}

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view {
    [super drawInteriorWithFrame:
     [self adjustedFrameToVerticallyCenterText:frame] inView:view];
}
@end
