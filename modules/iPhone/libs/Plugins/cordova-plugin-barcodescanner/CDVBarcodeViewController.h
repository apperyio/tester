//
//  CDVBarcodeViewController.h
//  FSIGO
//
//  Created by Donato Antonini on 12/09/2016.
//
//

#import <Foundation/Foundation.h>
#import "MTBBarcodeScanner.h"

#define RETURN_RESULT_BARCODE @"RETURN_RESULT_BARCODE"


@interface CDVBarcodeViewController : UIViewController {
    
    MTBBarcodeScanner *scanner;
    UIBarButtonItem* flash;
}

@property (nonatomic) CGRect frime;

- (id)initWithFrime:(CGRect)frime;

@end
