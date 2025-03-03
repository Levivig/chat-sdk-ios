//
//  ReactionView.h
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import <UIKit/UIKit.h>
#import "ReactionCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ReactionViewAlignmentLeft,
    ReactionViewAlignmentRight
} ReactionViewAlignment;

@interface ReactionView : UIView

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSDictionary *reactions;

@property (nonatomic) id<ReactionCellSelectionDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame alignment:(ReactionViewAlignment)alignment;
- (void)bindWithReactions:(NSDictionary*)reactions;
-(void)bindWithReactions:(NSDictionary*)reactions showAddButton:(BOOL)showAddButton;
- (void)setAlignment:(ReactionViewAlignment)alignment;
-(void)showAddButton;

@end

NS_ASSUME_NONNULL_END
