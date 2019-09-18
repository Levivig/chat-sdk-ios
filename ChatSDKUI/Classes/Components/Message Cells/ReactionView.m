//
//  ReactionView.m
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import <ChatSDK/UI.h>
#import "ReactionView.h"
#import "ReactionCell.h"

@implementation ReactionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTranslatesAutoresizingMaskIntoConstraints:false];
        [self initStackView];
    }
    return self;
}

-(void)initStackView {
    _stackView = [[UIStackView alloc] initWithFrame:self.frame];
    [self addSubview:_stackView];
    _stackView.keepEdgeAlignTo(self).equal = true;
}

-(void)bindWithReactions:(NSDictionary*)reactions {
    for (UIView* view in _stackView.arrangedSubviews) {
        [view removeFromSuperview];
    }
    
    for (NSString *key in reactions.allKeys) {
        ReactionCell *cell = [[ReactionCell alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
        NSNumber *count = reactions[key];
        [cell bindWithEmoji:key count:count.intValue];
        [_stackView addArrangedSubview:cell];
    }
}

@end
