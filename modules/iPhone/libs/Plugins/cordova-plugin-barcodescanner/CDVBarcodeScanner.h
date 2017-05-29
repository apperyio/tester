//
//  CDVBarcodeScanner.h
//  FSIGO
//
//  Created by Donato Antonini on 12/09/2016.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>



@interface CDVBarcodeScanner  : CDVPlugin {
    
    CDVInvokedUrlCommand* _command;
}

- (void)scan:(CDVInvokedUrlCommand*)command;
- (void)encode:(CDVInvokedUrlCommand*)command;



@end
