//
//  ReactionView.m
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import <ChatSDK/UI.h>
#import "ReactionView.h"

@implementation ReactionView {
    CGFloat leftInset;
    CGFloat rightInset;
    
    int numberOfItemsPerRow;
    
    ReactionViewAlignment alignment;
}

- (instancetype)initWithFrame:(CGRect)frame alignment:(ReactionViewAlignment)alignment
{
    self = [super initWithFrame:frame];
    if (self) {
        
        leftInset = 50;
        rightInset = 10;
        numberOfItemsPerRow = 5;
        self.alignment = alignment;
        
        [self setTranslatesAutoresizingMaskIntoConstraints:false];
        [self initStackViewWithAlignment:alignment];
    }
    return self;
}

-(void)initStackViewWithAlignment:(ReactionViewAlignment)alignment {
    _stackView = [[UIStackView alloc] initWithFrame:self.frame];
    [_stackView setTranslatesAutoresizingMaskIntoConstraints:false];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.distribution = UIStackViewDistributionFillProportionally;
    _stackView.spacing = 4;
    _stackView.alignment = UIStackViewAlignmentLeading;
    [self addSubview:_stackView];
    switch (alignment) {
        case ReactionViewAlignmentLeft:
            _stackView.keepLeadingInset.equal = leftInset;
            break;
        case ReactionViewAlignmentRight:
            _stackView.keepTrailingInset.equal = rightInset;
            break;
        default:
            break;
    }
    _stackView.keepTopInset.equal = 0;
}

-(ReactionCell*)getAddButton {
    CGRect frame = CGRectMake(0, 0, 20, 20);
    ReactionCell *addButton = [[ReactionCell alloc] initWithFrame:frame];
    [addButton bindWithEmoji:@"+" count:[[NSNumber alloc] initWithInt:-1] isSelected:false];
    [addButton setDelegate:self.delegate];
    [addButton setLeftInset:8.0];
    [addButton setRightInset:8.0];
    [addButton setFrame:frame];
    return addButton;
}

-(UIStackView*)getRowViewWithReactions:(NSDictionary*)reactions withAddButton:(BOOL)withAddButton {
    CGRect frame = CGRectMake(0, 0, 125, 20);
    UIStackView *view = [[UIStackView alloc] initWithFrame:frame];
    view.axis = UILayoutConstraintAxisHorizontal;
    view.distribution = UIStackViewDistributionFillProportionally;
    view.spacing = 4;
    view.alignment = UIStackViewAlignmentLeading;
    [view setTranslatesAutoresizingMaskIntoConstraints:false];
    
    if (withAddButton) {
        ReactionCell *addButton = [self getAddButton];
        [view addArrangedSubview:addButton];
    }
    
    [reactions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ReactionCell *cell = [[ReactionCell alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
        NSArray *senderIds = (NSArray*)obj;
        BOOL isSelected = false;
        for (NSString *senderId in senderIds) {
            if ([senderId isEqualToString:[BChatSDK currentUserID]]) {
                isSelected = true;
            }
        }
        [cell bindWithEmoji:key count:[[NSNumber alloc] initWithInteger:[senderIds count]] isSelected:isSelected];
        [cell setDelegate:self.delegate];
        [view addArrangedSubview:cell];
    }];
    
    return view;
}

-(void)bindWithReactions:(NSDictionary*)reactions {
    if (reactions.count > 0) {
        [self bindWithReactions:reactions showAddButton:false];
    }
}

-(void)bindWithReactions:(NSDictionary*)reactions showAddButton:(BOOL)showAddButton {
    for (UIView* view in _stackView.arrangedSubviews) {
        [view removeFromSuperview];
    }
    __block int row = 0;
    __block int idx = 1;
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    __block NSMutableDictionary *mutable = [[NSMutableDictionary alloc] init];
    [reactions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [mutable setObject:obj forKey:key];
    }];
    
    NSArray *keys = [mutable allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [a compare:b];
    }];
    NSMutableArray *sortedValues = [NSMutableArray new];
    for(NSString *key in sortedKeys) {
        if (idx == numberOfItemsPerRow+1) {
            UIStackView *stackview = [self getRowViewWithReactions:dict withAddButton:row == 0];
            [_stackView addArrangedSubview:stackview];
            dict = [[NSMutableDictionary alloc] init];
            idx = 1;
            row++;
        } else {
            [dict setObject:[mutable objectForKey:key] forKey:key];
            idx++;
        }
    }
    
    
    UIStackView *stackview = [self getRowViewWithReactions:dict withAddButton:row == 0 && dict.count > 0 || dict.count == 0 && showAddButton];
    [_stackView addArrangedSubview:stackview];
}

-(void)showAddButton {
//    [_stackView removeFromSuperview];
//    [self initStackViewWithAlignment:alignment];
//    
//    UIView *view = [self getAddButton];
//    [_stackView addArrangedSubview: view];
//    _stackView.keepHeight.equal = 22;
//    _stackView.keepWidth.equal = 30;
//    [_stackView setNeedsUpdateConstraints];
//    [_stackView layoutIfNeeded];
}

-(void)setAlignment:(ReactionViewAlignment)alignment {
    switch (alignment) {
        case ReactionViewAlignmentLeft:
            _stackView.keepTrailingInset.equal = KeepNone;
            _stackView.keepLeadingInset.equal = leftInset;
            break;
        case ReactionViewAlignmentRight:
            _stackView.keepLeadingInset.equal = KeepNone;
            _stackView.keepTrailingInset.equal = rightInset;
            break;
        default:
            break;
    }
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

@end
