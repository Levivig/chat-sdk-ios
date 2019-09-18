//
//  ReactionCell.m
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import "ReactionCell.h"

@implementation ReactionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)bindWithEmoji:(NSString *)emoji count:(int)count {
    NSString *text;
    if (count == 1) {
        text = [NSString stringWithFormat:@"%@", emoji];
    } else {
        text = [NSString stringWithFormat:@"%@ %d", emoji, count];
    }
    [self setText:text];
}

@end
