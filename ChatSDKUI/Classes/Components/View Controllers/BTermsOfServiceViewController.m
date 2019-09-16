//
//  BTermsOfServiceController.m
//  ChatSDK
//
//  Created by Pepe Becker on 01/03/2019.
//  Copyright © 2019 Pepe Becker. All rights reserved.
//

#import "BTermsOfServiceViewController.h"

#import <ChatSDK/UI.h>

@implementation BTermsOfServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.navigationItem) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle t:bBack] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    }

    [self load];
}

- (void)load {
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
