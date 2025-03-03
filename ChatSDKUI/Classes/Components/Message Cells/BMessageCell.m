//
//  BMessageCelself.m
//  Chat SDK
//
//  Created by Benjamin Smiley-andrews on 27/09/2013.
//  Copyright (c) 2013 deluge. All rights reserved.
//

#import "BMessageCell.h"

#import <ChatSDK/UI.h>
#import <ChatSDK/Core.h>
#import <ChatSDK/PElmMessage.h>

@implementation BMessageCell {
    CGFloat height;
    int numberOfItemsPerRow;
}

@synthesize bubbleImageView;
@synthesize message = _message;
@synthesize profilePicture = _profilePicture;

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    height = 20;
    numberOfItemsPerRow = 5;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // They aren't selectable
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        // Make sure the selected color is white
        self.selectedBackgroundView = [[UIView alloc] init];

        // Bubble view
        bubbleImageView = [[UIImageView alloc] init];
        bubbleImageView.contentMode = UIViewContentModeScaleToFill;
        bubbleImageView.userInteractionEnabled = YES;

        [self.contentView addSubview:bubbleImageView];
        
        _profilePicture = [[UIImageView alloc] init];
        _profilePicture.contentMode = UIViewContentModeScaleAspectFill;
        _profilePicture.clipsToBounds = YES;
        
        [self.contentView addSubview:_profilePicture];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(bTimeLabelPadding, 0, 0, 0)];
        
        _timeLabel.font = [UIFont italicSystemFontOfSize:12];
        if(BChatSDK.config.messageTimeFont) {
            _timeLabel.font = BChatSDK.config.messageTimeFont;
        }

        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.userInteractionEnabled = NO;
        [_timeLabel setHidden:true];
        
        [self.contentView addSubview:_timeLabel];

        _readMessageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(bTimeLabelPadding, 0, 0, 0)];
        [self setReadStatus:bMessageReadStatusNone];
        [self.contentView addSubview:_readMessageImageView];
        
        UITapGestureRecognizer * profileTouched = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfileView)];
        _profilePicture.userInteractionEnabled = YES;
        [_profilePicture addGestureRecognizer:profileTouched];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showEmojiViewIfNeeded:)];
        [self addGestureRecognizer:longPress];
        
        CGRect frame = CGRectMake(0, self.frame.size.height-height, self.frame.size.width, height);
        BOOL isMine = [_message.userModel isEqual:BChatSDK.currentUser];
        ReactionViewAlignment alignment = isMine ? ReactionViewAlignmentRight : ReactionViewAlignmentLeft;
        _reactionView = [[ReactionView alloc] initWithFrame:frame alignment:alignment];
        [self.contentView addSubview:_reactionView];
        _reactionView.keepVerticalInsets.equal = 4;
        _reactionView.keepLeadingInset.equal = 0;
        _reactionView.keepTrailingInset.equal = 0;
        [_reactionView setDelegate:self];
        [_reactionView setNeedsUpdateConstraints];
        [_reactionView layoutIfNeeded];

    }
    return self;
}

-(void) setReadStatus: (bMessageReadStatus) status {
    NSString * imageName = Nil;

    switch (status) {
        case bMessageReadStatusNone:
            imageName = @"icn_message_received.png";
            break;
        case bMessageReadStatusDelivered:
            imageName = @"icn_message_delivered.png";
            break;
        case bMessageReadStatusRead:
            imageName = @"icn_message_read.png";
            break;
        default:
            break;
    }
    
    if (imageName) {
        _readMessageImageView.image = [NSBundle uiImageNamed:imageName];
    }
    else {
        _readMessageImageView.image = Nil;
    }
}

-(void) setMessage: (id<PElmMessage>) message {
    [self setMessage:message withColorWeight:1.0];
}

-(void) showActivityIndicator {
    [self.contentView addSubview:_activityIndicator];
    [_activityIndicator keepCenter];
    _activityIndicator.keepInsets.equal = 0;
    [_activityIndicator startAnimating];
    [self.contentView bringSubviewToFront:_activityIndicator];
}

-(void) hideActivityIndicator {
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
}

// Called to setup the current cell for the message
-(void) setMessage: (id<PElmMessage>) message withColorWeight: (float) colorWeight {
    
    // Set the message for later use
    _message = message;
    
    BOOL isMine = message.senderIsMe;
    if (isMine) {
        [self setReadStatus:message.messageReadStatus];
        [_reactionView setAlignment:ReactionViewAlignmentRight];
    }
    else {
        [self setReadStatus:bMessageReadStatusHide];
        [_reactionView setAlignment:ReactionViewAlignmentLeft];
    }
    _reactionView.keepVerticalInsets.equal = self.bubbleHeight + 4.0;
    
    bMessagePos position = message.messagePosition;
    id<PElmMessage> nextMessage = message.nextMessage;
    
    // Set the bubble to be the correct color
    bubbleImageView.image = [[BMessageCache sharedCache] bubbleForMessage:message withColorWeight:colorWeight];

    // Hide profile pictures for 1-to-1 threads
    _profilePicture.hidden = self.profilePictureHidden;
    
    // We only want to show the user picture if it is the latest message from the user
    if (_message.senderIsMe) {
        _profilePicture.hidden = true;
    } else if (message.userModel.entityID != message.nextMessage.userModel.entityID  || _message.nextMessage == nil) {
        if (message.userModel) {
            [_profilePicture loadAvatar:message.userModel];
        }
        else {
            // If the user doesn't have a profile picture set the default profile image
            _profilePicture.image = message.userModel.defaultImage;
            _profilePicture.backgroundColor = [UIColor whiteColor];
        }
    }
    else {
        _profilePicture.image = nil;
    }
    
    if (message.flagged.intValue) {
        _timeLabel.text = [NSBundle t:bFlagged];
    }

    _timeLabel.text = _message.date.messageTimeAt;
    // We use 10 here because if the messages are less than 10 minutes apart, then we
    // can just compare the minute figures. If they were hours apart they could have
    // the same number of minutes
    if (nextMessage && [nextMessage.date minutesFrom:message.date] < 10) {
        if (message.date.minute == nextMessage.date.minute && [message.userModel isEqual: nextMessage.userModel]) {
            _timeLabel.text = Nil;
        }
    }
    
    // Hide the read receipt view if this is a public thread or if read receipts are disabled
    _readMessageImageView.hidden = _message.thread.type.intValue & bThreadFilterPublic || !BChatSDK.readReceipt;
}

-(void) willDisplayCell {
    
    // Add an extra margin if there is no profile picture
    UIEdgeInsets margin = self.bubbleMargin;
    UIEdgeInsets padding = self.bubblePadding;
    
    // Set the margins and height for message
    [bubbleImageView setFrame:CGRectMake(margin.left,
                                         margin.top,
                                         self.bubbleWidth,
                                         self.bubbleHeight)];
    
    // #1 Because of the text view insets we want the cellContentView of the
    // text cell to extend to the right edge of the bubble
    BOOL isMine = [_message.userModel isEqual:BChatSDK.currentUser];
    
    // Layout the profile picture
    if (_profilePicture.isHidden) {
        _profilePicture.frame = CGRectZero;
    }
    else {
        float ppDiameter = [BMessageCell profilePictureDiameter];
        float ppPadding = self.profilePicturePadding;

        [_profilePicture setFrame:CGRectMake(ppPadding,
                                             (self.cellHeight - ppDiameter - self.nameHeight - margin.bottom),
                                             ppDiameter,
                                             ppDiameter)];
        
        _profilePicture.layer.cornerRadius = ppDiameter / 2.0;
    }
    
    // Update the content view size for the message length
    // The cell content view is the view that's inside the bubble that stores the message content
    [self cellContentView].frame = CGRectMake((isMine ? 0 : bTailSize) + padding.left, padding.top, self.contentWidth, self.contentHeight);
    
//    NSLog(@"Content Size: %@", NSStringFromCGRect([self cellContentView].frame));
//    NSLog(@"Text Width: %f", [BMessageCell textWidth:_message.textString maxWidth:[self maxTextWidth]]);

}


// Format the cells properly when the device orientation changes
-(void) layoutSubviews {
    [super layoutSubviews];
    
    BOOL isMine = [_message.userModel isEqual:BChatSDK.currentUser];
    
    // Extra x-margin if the profile picture isn't shown
    // TODO: Fix this
    float xMargin =  _profilePicture.image ? 0 : 0;
    
    // Layout the date label this will be the full size of the cell
    // This will automatically center the text in the y direction
    // we'll set the side using text alignment
    [_timeLabel setViewFrameWidth:self.fw - bTimeLabelPadding * 2.0];
    
    // We don't want the label getting in the way of the read receipt
    [_timeLabel setViewFrameHeight:self.cellHeight * 0.8];
    
    [_readMessageImageView setViewFrameWidth:bReadReceiptWidth];
    [_readMessageImageView setViewFrameHeight:bReadReceiptHeight];
    [_readMessageImageView setViewFrameY:_timeLabel.fh * 2.0 / 3.0];
    
    // Make the width less by the profile picture width means the name and profile picture are inline
    
    // Layout the bubble
    // The bubble is translated the "margin" to the right of the profile picture
    if (!isMine) {
        [_profilePicture setViewFrameX:_profilePicture.hidden ? 0 : self.profilePicturePadding];
        [bubbleImageView setViewFrameX:self.bubbleMargin.left + _profilePicture.fx + _profilePicture.fw + xMargin];
        
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    else {
        [_profilePicture setViewFrameX:_profilePicture.hidden ? self.contentView.fw : self.contentView.fw - _profilePicture.fw - self.profilePicturePadding];
        [bubbleImageView setViewFrameX:_profilePicture.fx - self.bubbleWidth - self.bubbleMargin.right - xMargin];
        
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    
//        self.bubbleImageView.layer.borderColor = UIColor.redColor.CGColor;
//        self.bubbleImageView.layer.borderWidth = 1;
//        self.contentView.layer.borderColor = UIColor.blueColor.CGColor;
//        self.contentView.layer.borderWidth = 1;
//        self.cellContentView.layer.borderColor = UIColor.greenColor.CGColor;
//        self.cellContentView.layer.borderWidth = 1;
}


-(BOOL) profilePictureHidden {
    return [BMessageCell profilePictureHidden:_message];
}

+(BOOL) profilePictureHidden: (id<PElmMessage>) message {
    return message.thread.type.intValue & bThreadType1to1 && !BChatSDK.config.showUserAvatarsOn1to1Threads;
}

// Open the users profile
-(void) showProfileView {
    if (!_message.userModel.isMe) {
        id<PUser> user = [BChatSDK.db fetchEntityWithID:_message.userModel.entityID withType:bUserEntity];
        if ([[[user meta] objectForKey:@"isAdmin"] boolValue]) {
            [[[BChatSDK shared] messageSelectorDelegate] didSelectAdminUser];
        } else {
            if (_message.thread.type.intValue == bThreadTypePublicGroup || _message.thread.type.intValue == bThreadTypePrivateGroup) {
                [[[BChatSDK shared] messageSelectorDelegate] didSelectUserWithEntityId:_message.userModel.entityID];
            }
        }
    }
}

-(UIView *) cellContentView {
    NSLog(@"Method: cellContentView must be implemented in sub classes");
    assert(1 == 0);
    return Nil;
}

// Change the color of a bubble. This method takes an image and loops over
// the pixels changing any non-zero pixels to the new color

// MEM1
+(UIImage *) bubbleWithImage: (UIImage *) bubbleImage withColor: (UIColor *) color {
    
    // Get a CGImageRef so we can use CoreGraphics
    CGImageRef image = bubbleImage.CGImage;
    
    CGFloat width = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    
    // Create a new bitmap context i.e. a buffer to store the pixel data
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel    = 4;
    size_t bytesPerRow      = (width * bitsPerComponent * bytesPerPixel + 7) / 8; // As per the header file for CGBitmapContextCreate
    size_t dataSize         = bytesPerRow * height;
    
    // Allocate some memory to store the pixels
    unsigned char *data = malloc(dataSize);
    memset(data, 0, dataSize);
    
    // Create the context
    CGContextRef context = CGBitmapContextCreate(data, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // Draw the image onto the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    // Get the components of our input color
    const CGFloat * colors = CGColorGetComponents(color.CGColor);
    
    // Change the pixels which have alpha > 0 to our new color
    for (int i  = 0 ; i < width * height * 4 ; i+=4)
    {
        // If alpha is not zero
        if (data[i+3] != 0) {
            data[i] = (char) (colors[0] * 255);
            data[i + 1] = (char) (colors[1] * 255);
            data[i + 2] = (char) (colors[2] * 255);
        }
    }
    
    NSInteger leftCapWidth = bubbleImage.leftCapWidth;
    NSInteger topCapHeight = bubbleImage.topCapHeight;
    
    // Write from the context to our new image
    // Make sur to copy across the orientation and scale so the bubbles render
    // properly on a retina screen
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * newImage = [[UIImage imageWithCGImage:imageRef
                                              scale:bubbleImage.scale
                                        orientation:bubbleImage.imageOrientation] stretchableImageWithLeftCapWidth:leftCapWidth
                                                                                                             topCapHeight:topCapHeight];
    // Free up the memory we used
    CGImageRelease(imageRef);
    CGContextRelease(context);
    free(data);
    CGColorSpaceRelease(colorSpace);
    
    return newImage;
}

-(BOOL) supportsCopy {
    return NO;
}

// Layout Methods

-(float) contentHeight {
    return [BMessageCell contentHeight:_message];
}

+(float) contentHeight: (id<PElmMessage>) message {
    return [self contentHeight:message maxWidth:[self maxTextWidth:message]];
}

+(float) contentHeight: (id<PElmMessage>) message maxWidth: (float) maxWidth {
    
    // Get the cell type
    Class cellType = [BChatSDK.ui cellTypeForMessageType:message.type];
    
    SEL selector = @selector(messageContentHeight:maxWidth:);
    if ([cellType respondsToSelector:selector]) {
        return [[cellType performSelector:selector withObject:message withObject: @(maxWidth)] floatValue];
    }
    
    return [self messageContentHeight:message maxWidth:maxWidth].floatValue;
}

-(float) contentWidth {
    return [BMessageCell contentWidth:_message maxWidth:self.maxTextWidth];
}

+(float) contentWidth: (id<PElmMessage>) message {
    return [self contentWidth:message maxWidth:[self maxTextWidth:message]];
}

+(float) contentWidth: (id<PElmMessage>) message maxWidth: (float) maxWidth {
    
    Class cellType = [BChatSDK.ui cellTypeForMessageType:message.type];
    
    SEL selector = @selector(messageContentWidth:maxWidth:);
    if ([cellType respondsToSelector:selector]) {
        return [[cellType performSelector:selector withObject:message withObject: @(maxWidth)] floatValue];
    }
    
    return [self messageContentWidth:message maxWidth:maxWidth].floatValue;
}


+(float) maxTextWidth: (id<PElmMessage>) message {
    UIEdgeInsets padding = [self bubblePadding:message];
    return [self maxBubbleWidth:message] - padding.left - padding.right;
}

+(float) maxBubbleWidth: (id<PElmMessage>) message {
    UIEdgeInsets bubbleMargin = [self bubbleMargin:message];
    return [self currentSize].width - bMessageMarginX - ([self profilePictureHidden:message] ? 0 : self.profilePictureDiameter + [self profilePicturePadding:message]) - bubbleMargin.left - bubbleMargin.right;
}

-(float) bubbleHeight {
    return [BMessageCell bubbleHeight:_message maxWidth:self.maxTextWidth];
}

//+(float) bubbleHeight: (id<PElmMessage>) message {
//
//}

+(float) bubbleHeight: (id<PElmMessage>) message maxWidth: (float) maxWidth {
    UIEdgeInsets padding = [BMessageCell bubblePadding:message];
    return [BMessageCell contentHeight:message maxWidth:maxWidth] + padding.top + padding.bottom;
}

-(float) cellHeight {
    return [BMessageCell cellHeight:_message maxWidth:self.maxTextWidth];
}

+(float) cellHeight: (id<PElmMessage>) message maxWidth: (float) maxWidth {
    UIEdgeInsets bubbleMargin = [self bubbleMargin:message];
    return [BMessageCell bubbleHeight:message maxWidth:maxWidth] + bubbleMargin.top + bubbleMargin.bottom + [self nameHeight:message];
}

+(float) cellHeight: (id<PElmMessage>) message {
    float maxWidth = [self maxTextWidth:message];
    UIEdgeInsets bubbleMargin = [self bubbleMargin:message];
    return [BMessageCell bubbleHeight:message maxWidth:maxWidth] + bubbleMargin.top + bubbleMargin.bottom + [self nameHeight:message];
}

-(float) nameHeight {
    return [BMessageCell nameHeight:_message];
}

+(float) nameHeight: (id<PElmMessage>) message {
    return 0;
}

-(float) bubbleWidth {
    return [BMessageCell bubbleWidth:_message maxWidth:self.maxTextWidth];
}

+(float) bubbleWidth: (id<PElmMessage>) message maxWidth: (float) maxWidth {
    UIEdgeInsets padding = [self bubblePadding: message];
    return [BMessageCell contentWidth: message maxWidth:maxWidth] + padding.left + padding.right;
}

// The margin outside the bubble
-(UIEdgeInsets) bubbleMargin {
    return [BMessageCell bubbleMargin:_message];
}

// The padding inside the bubble - i.e. between the bubble and the content
+(UIEdgeInsets) bubbleMargin: (id<PElmMessage>) message {
    NSValue * value = [BChatSDK.config messageBubbleMarginForType:message.type.intValue];
    value = value ? value : [BChatSDK.config messageBubbleMarginForType:bMessageTypeAll];
    if (value) {
        return [value UIEdgeInsetsValue];
    }
    
    Class cellType = [BChatSDK.ui cellTypeForMessageType:message.type];

    SEL selector = @selector(messageBubbleMargin:);
    if ([cellType respondsToSelector:selector]) {
        return [[cellType performSelector:selector withObject:message] UIEdgeInsetsValue];
    }
    
    return [self messageBubbleMargin:message].UIEdgeInsetsValue;
}

-(UIEdgeInsets) bubblePadding {
    return [BMessageCell bubblePadding:_message];
}

+(UIEdgeInsets) bubblePadding: (id<PElmMessage>) message {
    NSValue * value = [BChatSDK.config messageBubblePaddingForType:message.type.intValue];
    value = value ? value : [BChatSDK.config messageBubblePaddingForType:bMessageTypeAll];
    if (value) {
        return [value UIEdgeInsetsValue];
    }
    
    Class cellType = [BChatSDK.ui cellTypeForMessageType:message.type];

    SEL selector = @selector(messageBubblePadding:);
    if ([cellType respondsToSelector:selector]) {
        return [[cellType performSelector:selector withObject:message] UIEdgeInsetsValue];
    }

    return [self messageBubblePadding:message].UIEdgeInsetsValue;
}

-(float) profilePicturePadding {
    return [BMessageCell profilePicturePadding:_message];
}

+(float) profilePicturePadding: (id<PElmMessage>) message {
    
    Class cellType = [BChatSDK.ui cellTypeForMessageType:message.type];
    
    SEL selector = @selector(messageProfilePicturePadding:);
    if ([cellType respondsToSelector:selector]) {
        return [[cellType performSelector:selector withObject:message] floatValue];
    }
    
    return [self messageProfilePicturePadding:message].floatValue;
}

+(float) profilePictureDiameter {
    return bProfilePictureDiameter;
}

-(void) hideProfilePicture {
    _profilePicture.frame = CGRectZero;
}

-(float) maxTextWidth {
    return [BTextMessageCell maxTextWidth: _message];
}

+(CGSize) currentSize
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

#pragma Default cell sizing static methods

+(NSNumber *) messageContentHeight: (id<PElmMessage>) message maxWidth: (float) maxWidth {
    return @(100);
}

+(NSNumber *) messageContentWidth: (id<PElmMessage>) message maxWidth: (float) maxWidth {
    return @(bMaxMessageWidth);
}

+(NSValue *) messageBubblePadding: (id<PElmMessage>) message {
    return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
}

+(NSValue *) messageBubbleMargin: (id<PElmMessage>) message {
    return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(2.0, 2.0, 1.0, 2.0)];
}

+(NSNumber *) messageProfilePicturePadding: (id<PElmMessage>) message {
    return @(16);
}

-(void)setReactions:(NSDictionary *)reactions {
    _reactions = reactions;
    CGFloat reactionViewheight = ceil(((CGFloat)[_reactions count]) / numberOfItemsPerRow) * height;
    [_reactionView.keepHeight deactivate];
    _reactionView.keepHeight.equal = reactionViewheight < 10e-15 ? height : reactionViewheight;
    [_reactionView setNeedsLayout];
    [_reactionView layoutIfNeeded];
    [_reactionView bindWithReactions:reactions showAddButton:_showEmojiPicker];
}

-(void)showEmojiViewIfNeeded:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateRecognized && [_reactions count] == 0) {
        _showEmojiPicker = true;
        [_reactionView.keepHeight deactivate];
        _reactionView.keepHeight.equal = height;
        [_reactionView setNeedsLayout];
        [_reactionView layoutIfNeeded];
        [_reactionView showAddButton];
        [self.reactionDelegate showAddButtonForMessageID:_message.entityID isLast: _message.nextMessage == nil];
    }
}

- (void)didSelectEmoji:(NSString *)emoji {
    [self.reactionDelegate didSelectEmoji:emoji forMessageID:_message.entityID];
}

- (void)didDeselectEmoji:(NSString *)emoji {
    [self.reactionDelegate didDeSelectEmoji:emoji forMessageID:_message.entityID];
}

- (void)didSelectAddButton {
    [self.reactionDelegate didSelectAddButtonForMessageID:_message.entityID];
}

- (void)setShowEmojiPicker:(BOOL)showEmojiPicker {
    _showEmojiPicker = showEmojiPicker;
    [_reactionView bindWithReactions:_reactions showAddButton:_showEmojiPicker];
}

@end
