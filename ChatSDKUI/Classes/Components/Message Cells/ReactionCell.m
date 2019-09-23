//
//  ReactionCell.m
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import "ReactionCell.h"

@implementation ReactionCell {
    UIColor *selectedColor;
    UIColor *notSelectedColor;
    
    NSString *emoji;
    NSNumber *count;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    _leftInset = 5.0;
    _rightInset = 5.0;
    _topInset = 5.0;
    _bottomInset = 5.0;
    
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
        [self setTranslatesAutoresizingMaskIntoConstraints:false];
    }
    return self;
}

- (void)bindWithEmoji:(NSString *)emoji_ count:(NSNumber*)count_ isSelected:(BOOL)isSelected {
    emoji = emoji_;
    count = count_;
    [self setIsSelected:isSelected];
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
    [super drawTextInRect: CGRectInset(rect, _leftInset, _topInset) ];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + _leftInset + _rightInset, size.height + _topInset + _bottomInset);
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
    
    if (_isSelected) {
        [self.delegate didDeselectEmoji:emoji];
    } else {
        [self.delegate didSelectEmoji:emoji];
    }
    [self setIsSelected:!_isSelected];
}

@end
