//
//  BMessageReactionDelegate.h
//  Pods
//
//  Created by Levente Vig on 2019. 09. 19..
//

#ifndef BMessageReactionDelegate_h
#define BMessageReactionDelegate_h

@protocol BMessageReactionDelegate <NSObject>

- (void)didSelectAddButtonForMessageID:(NSString*)messageId;
- (void)didSelectEmoji:(NSString*)emoji forMessageID:(NSString*)messageId;
- (void)didDeSelectEmoji:(NSString*)emoji forMessageID:(NSString*)messageId;

@end

#endif /* BMessageReactionDelegate_h */
