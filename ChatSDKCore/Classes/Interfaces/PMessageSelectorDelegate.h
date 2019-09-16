//
//  PMessageSelectorDelegate.h
//  Pods
//
//  Created by Levente Vig on 2019. 09. 16..
//

#ifndef PMessageSelectorDelegate_h
#define PMessageSelectorDelegate_h

@protocol PMessageSelectorDelegate

/**
 * @brief Send a video message
 */
-(void)didSelectUserWithEntityId:(NSString*)entityId;
-(void)didSelectAdminUser;

@end

#endif /* PMessageSelectorDelegate_h */
