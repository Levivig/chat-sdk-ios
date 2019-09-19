//
//  ReactionCell.h
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import <UIKit/UIKit.h>
#import "ReactionCellSelectionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReactionCell : UILabel

@property (nonatomic) BOOL isSelected;
@property (nonatomic) id<ReactionCellSelectionDelegate> delegate;

- (void)bindWithEmoji:(NSString *)emoji_ count:(NSNumber*)count isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
