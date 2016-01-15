//
//  EXSAMLResponseSerializer.m
//  Appery
//
//  Created by Sergey Tkachenko on 12/2/15.
//  Copyright (c) 2015 Exadel Inc. All rights reserved.
//

#import "EXSAMLResponseSerializer.h"

#import "Ono.h"
#import "NSString+URLUtility.h"
#import "EXSAMLResponse.h"

@interface EXSAMLResponseSerializer ()

/**
 * Filter HTML source, remove coments
 */
- (NSString *)filterHtml:(NSString *)html;

@end

@implementation EXSAMLResponseSerializer

+ (instancetype)serializer
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"text/html", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        return nil;
    }
    
    NSString *dirtyHtml = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *cleanHtml = [self filterHtml:dirtyHtml];
    
    NSError *serializationError = nil;
    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:cleanHtml encoding:NSUTF8StringEncoding error:&serializationError];
    
    NSString *action = [document firstChildWithXPath:@"BODY/FORM"][@"ACTION"];
    NSString *value  = [document firstChildWithXPath:@"BODY/FORM/INPUT"][@"VALUE"];
    
    //TODO: check value & actions
    if (error) {
        *error = serializationError;
    }
    
    return [[EXSAMLResponse alloc] initWithValue:value andActions:action];
}

#pragma mark - Private

- (NSString *)filterHtml:(NSString *)html
{
    NSString  *text = nil;
    NSScanner *scanner = [NSScanner scannerWithString:html];
    
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:@"<!--" intoString:NULL];
        [scanner scanUpToString:@"-->" intoString:&text];
        
        if (text != nil) {
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-->", text] withString:@""];
        }
    }
    
    return html;
}

@end
