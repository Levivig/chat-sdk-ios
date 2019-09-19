//
//  ReactionCellSelectionDelegate.h
//  Pods
//
//  Created by Levente Vig on 2019. 09. 19..
//

NS_ASSUME_NONNULL_BEGIN

@protocol ReactionCellSelectionDelegate <NSObject>

-(void)didSelectAddButton;

-(void)didSelectEmoji:(NSString*)emoji;
-(void)didDeselectEmoji:(NSString*)emoji;

@end

NS_ASSUME_NONNULL_END
