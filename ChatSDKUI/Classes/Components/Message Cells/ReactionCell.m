//
//  ReactionCell.m
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import "ReactionCell.h"

@implementation ReactionCell {
    CGFloat leftInset;
    CGFloat rightInset;
    CGFloat topInset;
    CGFloat bottomInset;
    
    UIColor *selectedColor;
    UIColor *notSelectedColor;
    
    NSString *emoji;
    NSNumber *count;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    leftInset = 5.0;
    rightInset = 5.0;
    topInset = 5.0;
    bottomInset = 5.0;
    
    selectedColor = [[UIColor alloc] initWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    notSelectedColor = [[UIColor alloc] initWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setFont:[UIFont systemFontOfSize:9]];
        [self setBackgroundColor: notSelectedColor];
        _isSelected = false;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:tap];
        [self setUserInteractionEnabled:true];
    }
    return self;
}

- (void)bindWithEmoji:(NSString *)emoji_ count:(NSNumber*)count_ isSelected:(BOOL)isSelected {
    emoji = emoji_;
    count = count_;
    NSString *text;
    if ([count_ isEqualToNumber:[[NSNumber alloc] initWithInt:1]] || [count_ isEqualToNumber:[[NSNumber alloc] initWithInt:-1]]) {
        text = [NSString stringWithFormat:@"%@", emoji];
    } else {
        text = [NSString stringWithFormat:@"%@ %@", emoji, count_];
    }
    [self setText:text];
    [self sizeToFit];
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect: CGRectInset(rect, leftInset, topInset) ];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + leftInset + rightInset, size.height + topInset + bottomInset);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self.layer setCornerRadius:self.frame.size.height / 2.0];
    [self.layer setMasksToBounds:true];
}

-(void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        [self setBackgroundColor: selectedColor];
    } else {
        [self setBackgroundColor: notSelectedColor];
    }
}

-(void)didTap {
    if ([count isEqualToNumber:[[NSNumber alloc] initWithInt:-1]]) {
        [self.delegate didSelectAddButton];
        return;
    }
    
    [self setIsSelected:!_isSelected];
    if (_isSelected) {
        [self.delegate didDeselectEmoji:emoji];
    } else {
        [self.delegate didSelectEmoji:emoji];
    }
}

@end
