//
//  ReactionCell.h
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReactionCell : UILabel

-(void)bindWithEmoji:(NSString*)emoji count:(int)count;

@end

NS_ASSUME_NONNULL_END
