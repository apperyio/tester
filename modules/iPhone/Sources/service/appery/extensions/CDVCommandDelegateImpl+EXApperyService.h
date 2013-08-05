//
//  CDVCommandDelegateImpl+EXApperyService.h
//  Appery
//
//  Created by Sergey Seroshtan on 21.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import <Cordova/CDVCommandDelegateImpl.h>

/**
 * This category ovverrides method pathForResource to provide access to resources not from main bundle
 *     but from the custom location.
 */
@interface CDVCommandDelegateImpl (EXApperyService)

@end
