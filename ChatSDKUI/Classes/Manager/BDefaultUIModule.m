//
//  BDefaultUIModule.m
//  AFNetworking
//
//  Created by Ben on 2/1/18.
//

#import "BDefaultUIModule.h"
#import <ChatSDK/Core.h>
#import <ChatSDK/UI.h>
#import <CoreText/CoreText.h>

@implementation BDefaultUIModule

-(void) activate {
    BChatSDK.shared.interfaceAdapter = [[BDefaultInterfaceAdapter alloc] init];
    // Set the login screen
    // TODO:
    //    BChatSDK.auth.challengeViewController = [[BLoginViewController alloc] initWithNibName:Nil bundle:Nil];
    if(!BChatSDK.config.defaultBlankAvatar) {
        BChatSDK.config.defaultBlankAvatar = [NSBundle imageNamed:bDefaultProfileImage bundle:bUIBundleName];
    }
    [self registerFontWithName:@"Poppins-Regular"];
    [self registerFontWithName:@"Poppins-Bold"];
}

-(void) registerFontWithName:(NSString*)fontName {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *fontURL = [bundle URLForResource:fontName withExtension:@"ttf"];
    NSData *inData = [NSData dataWithContentsOfURL:fontURL];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)inData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFSafeRelease(font);
    CFSafeRelease(provider);
}

void CFSafeRelease(CFTypeRef cf) {
    if (cf != NULL) {
        CFRelease(cf);
    }
}

@end
