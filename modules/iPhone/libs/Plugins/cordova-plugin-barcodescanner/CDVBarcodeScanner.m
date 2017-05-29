//
//  CDVBarcodeScanner.m
//  FSIGO
//
//  Created by Donato Antonini on 12/09/2016.
//
//

#import "CDVBarcodeScanner.h"
#import "MTBBarcodeScanner.h"
#import "CDVBarcodeViewController.h"

#define RETICLE_SIZE    500.0f
#define RETICLE_WIDTH    10.0f
#define RETICLE_OFFSET   60.0f
#define RETICLE_ALPHA     0.4f

@implementation CDVBarcodeScanner


- (NSString*)isScanNotPossible {
    NSString* result = nil;
    
    Class aClass = NSClassFromString(@"AVCaptureSession");
    if (aClass == nil) {
        return @"AVFoundation Framework not available";
    }
    
    return result;
}


- (void)scan:(CDVInvokedUrlCommand*)command {
    
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (!success) {
            [self showAlertPermissionProhibited];
        }else {
           NSString* capabilityError = [self isScanNotPossible];
            if (capabilityError) {
                [self returnError:capabilityError callback:command.callbackId];
                return;
            }
            
            [self scanInit:command];
        }
    }];

}

- (void)encode:(CDVInvokedUrlCommand*)command {
}

- (void)scanInit:(CDVInvokedUrlCommand*)command {
     _command = command;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultPlugin:) name:RETURN_RESULT_BARCODE object:nil];
    
    [self.viewController presentViewController:[[CDVBarcodeViewController alloc] initWithFrime:self.viewController.view.bounds] animated:YES completion:nil];

}

-(void) resultPlugin:(NSNotification *)result {
   
    [self returnSuccess:[(NSDictionary *) result.object objectForKey:@"code"] cancelled:[[(NSDictionary *)result.object objectForKey:@"cancelled"] isEqualToString:@"YES"]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) showAlertPermissionProhibited {
    NSString* settingsButton = NSLocalizedString(@"Settings", nil);
    [[[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle]
                                         objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                message:NSLocalizedString(@"Access to the camera has been prohibited; please enable it in the Settings app to continue.", nil)
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:settingsButton, nil] show];
}

- (void)returnError:(NSString*)message callback:(NSString*)callback {
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsString: message
                               ];
    
    [self.commandDelegate sendPluginResult:result callbackId:callback];
}

- (void)returnSuccess:(NSString*)scannedText  cancelled:(BOOL)cancelled {
    NSNumber* cancelledNumber = [NSNumber numberWithInt:(cancelled?1:0)];
    
    NSMutableDictionary* resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:scannedText     forKey:@"text"];
    [resultDict setObject:@"QR_CODE"      forKey:@"format"];
    [resultDict setObject:cancelledNumber forKey:@"cancelled"];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    [self.commandDelegate sendPluginResult:result callbackId:_command.callbackId];
}




@end
