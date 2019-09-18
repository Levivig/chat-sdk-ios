//
//  ReactionView.h
//  ChatSDK
//
//  Created by Levente Vig on 2019. 09. 18..
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReactionView : UIView

@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSDictionary *reactions;

-(void)bindWithReactions:(NSDictionary*)reactions;

@end

NS_ASSUME_NONNULL_END
