//
//  CDVBarcodeViewController.m
//  FSIGO
//
//  Created by Donato Antonini on 12/09/2016.
//
//

#import "CDVBarcodeViewController.h"
#import "MTBBarcodeScanner.h"
#import <AVFoundation/AVFoundation.h>


#define RETICLE_SIZE    500.0f
#define RETICLE_WIDTH    10.0f
#define RETICLE_OFFSET   60.0f
#define RETICLE_ALPHA     0.4f

@implementation CDVBarcodeViewController


- (id)initWithFrime:(CGRect)frime {
    self = [super init];
    if (!self) return self;
    
    _frime = frime;
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [scanner startScanningWithResultBlock:^(NSArray *codes) {
        AVMetadataMachineReadableCodeObject *code = [codes firstObject];
        NSLog(@"Found code: %@", code.stringValue);
        
        NSDictionary *d = @{ @"code":code.stringValue, @"cancelled":@"NO"};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RETURN_RESULT_BARCODE object:d];

        [scanner stopScanning];
        
         [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


-(void) loadView {
    
    self.view = [[UIView alloc] initWithFrame: _frime];
    
    scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.view];
    
    [self.view addSubview:[self buildOverlayView]];

}


- (UIView*)buildOverlayView {
    
  
    CGRect bounds = self.view.bounds;
    bounds = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    
    UIView* overlayView = [[UIView alloc] initWithFrame:bounds];
    overlayView.autoresizesSubviews = YES;
    overlayView.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.opaque              = NO;
    
    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    id cancelButton = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                       target:(id)self
                       action:@selector(cancelButtonPressed:)
                       
                       ];
    
    flash = [[UIBarButtonItem alloc]
             initWithImage:[UIImage imageNamed:@"barcode.bundle/flash_off.png"]
             style:UIBarButtonItemStylePlain
             target:self
             action:@selector(flashButtonPressed:)
             ];
    
    id flexSpace = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                    target:nil
                    action:nil
                    ];
    
    id flipCamera = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                     target:(id)self
                     action:@selector(flipCameraButtonPressed:)
                     ];
    
#if USE_SHUTTER
    id shutterButton = [[UIBarButtonItem alloc]
                        initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                        target:(id)self
                        action:@selector(shutterButtonPressed)
                        ];
    
    if ([CDVbcsProcessor hasFlash]) {
        toolbar.items = [NSArray arrayWithObjects:flexSpace,cancelButton,flexSpace, flipCamera ,shutterButton,flash,nil];
    }else {
        toolbar.items = [NSArray arrayWithObjects:flexSpace,cancelButton,flexSpace, flipCamera ,shutterButton,nil];
    }
#else
    if ([self hasFlash]) {
        toolbar.items = [NSArray arrayWithObjects:flexSpace,cancelButton,flexSpace, flipCamera,flash,nil];
    }else {
        toolbar.items = [NSArray arrayWithObjects:flexSpace,cancelButton,flexSpace, flipCamera,nil];
    }
#endif
    bounds = overlayView.bounds;
    
    [toolbar sizeToFit];
    CGFloat toolbarHeight  = [toolbar frame].size.height;
    CGFloat rootViewHeight = CGRectGetHeight(bounds);
    CGFloat rootViewWidth  = CGRectGetWidth(bounds);
    CGRect  rectArea       = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    [toolbar setFrame:rectArea];
    
    [overlayView addSubview: toolbar];
    
    UIImage* reticleImage = [self buildReticleImage];
    UIView* reticleView = [[UIImageView alloc] initWithImage: reticleImage];
    CGFloat minAxis = MIN(rootViewHeight, rootViewWidth);
    
    rectArea = CGRectMake(
                          0.5 * (rootViewWidth  - minAxis),
                          0.5 * (rootViewHeight - minAxis),
                          minAxis,
                          minAxis
                          );
    
    [reticleView setFrame:rectArea];
    
    reticleView.opaque           = NO;
    reticleView.contentMode      = UIViewContentModeScaleAspectFit;
    reticleView.autoresizingMask = 0
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin
    ;
    
    [overlayView addSubview: reticleView];
    
    return overlayView;
}

-(BOOL) hasFlash {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return [device hasTorch] && [device hasFlash];
}

- (UIImage*)buildReticleImage {
    UIImage* result;
    UIGraphicsBeginImageContext(CGSizeMake(RETICLE_SIZE, RETICLE_SIZE));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor* colorRedLine = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:RETICLE_ALPHA];
    CGContextSetStrokeColorWithColor(context, colorRedLine.CGColor);
    CGContextSetLineWidth(context, RETICLE_WIDTH);
    CGContextBeginPath(context);
    CGFloat lineOffset = RETICLE_OFFSET+(0.5*RETICLE_WIDTH);
    CGContextMoveToPoint(context, lineOffset, RETICLE_SIZE/2);
    CGContextAddLineToPoint(context, RETICLE_SIZE-lineOffset, 0.5*RETICLE_SIZE);
    CGContextStrokePath(context);
    
    UIColor* color = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:RETICLE_ALPHA];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, RETICLE_WIDTH);
    CGContextStrokeRect(context,
                        CGRectMake(
                                   RETICLE_OFFSET,
                                   RETICLE_OFFSET,
                                   RETICLE_SIZE-2*RETICLE_OFFSET,
                                   RETICLE_SIZE-2*RETICLE_OFFSET
                                   )
                        );
    
    
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (void)flipCameraButtonPressed:(id)sender
{
    [scanner flipCamera];

}

- (void)cancelButtonPressed:(id)sender
{
    [scanner stopScanning];
    NSDictionary *d = @{ @"code":@"", @"cancelled":@"YES"};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RETURN_RESULT_BARCODE object:d];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (IBAction)flashButtonPressed:(id)sender {
    if (scanner.torchMode == MTBTorchModeOff || scanner.torchMode == MTBTorchModeAuto) {
        scanner.torchMode = MTBTorchModeOn;
         [flash setImage:[UIImage imageNamed:@"barcode.bundle/flash_on.png"]];
    } else {
        scanner.torchMode = MTBTorchModeOff;
         [flash setImage:[UIImage imageNamed:@"barcode.bundle/flash_off.png"]];
    }
}

@end
