//
//  EXCredentialsManager.m
//  Appery
//
//  Created by Sergey Seroshtan on 21.08.12.
//  Copyright (c) 2013 Exadel Inc. All rights reserved.
//

#import "EXCredentialsManager.h"

@implementation EXCredentialsManager

- (BOOL) addPassword: (NSString *)password forUser: (NSString *)userName
{
    NSMutableDictionary *itemAttributesForSearching = [[NSMutableDictionary alloc] init];
    
    [itemAttributesForSearching setObject: (id)kSecClassGenericPassword forKey: (id)kSecClass];
    [itemAttributesForSearching setObject: (id)kCFBooleanTrue forKey: (id)kSecReturnAttributes];
    
    NSMutableDictionary *foundedItem = nil;
    
    if(SecItemCopyMatching((CFDictionaryRef) itemAttributesForSearching,(CFTypeRef *) &foundedItem) == noErr) {
        // updating existing item
        NSMutableDictionary *attributesToUpdate = [[NSMutableDictionary alloc] init];
        [attributesToUpdate setObject: (id)(CFDataRef) [userName dataUsingEncoding:NSUTF8StringEncoding]
                               forKey: (id)kSecAttrAccount];
        [attributesToUpdate setObject: (id)(CFDataRef) [password dataUsingEncoding:NSUTF8StringEncoding]
                               forKey: (id)kSecValueData]; 
        
        NSMutableDictionary *updateItem = [NSMutableDictionary dictionaryWithDictionary: foundedItem];
        [updateItem setObject: (id)kSecClassGenericPassword forKey: (id)kSecClass];
        
        OSStatus updateStatus = SecItemUpdate((CFDictionaryRef)updateItem , (CFDictionaryRef)attributesToUpdate);
       
        [attributesToUpdate release];
        [itemAttributesForSearching release];
        
        return updateStatus == noErr;
    } else {
    
         //deleting option for result of searhing
        [itemAttributesForSearching removeObjectForKey: (id) kSecReturnAttributes];     
        [itemAttributesForSearching setObject: (id)(CFDataRef)[userName dataUsingEncoding:NSUTF8StringEncoding]
                                       forKey: (id)kSecAttrAccount];
        [itemAttributesForSearching setObject: (id)(CFDataRef)[password dataUsingEncoding:NSUTF8StringEncoding]
                                       forKey: (id)kSecValueData];
        
        OSStatus addStatus = SecItemAdd((CFDictionaryRef)itemAttributesForSearching, nil);
        
        [itemAttributesForSearching release];
        return addStatus == noErr;
    }
}

- (BOOL) removePasswordForUser: (NSString *)userName
{
    return NO;
}

- (NSString *) retreivePasswordForUser: (NSString *)userName
{
    
    NSMutableDictionary *itemAttributesForSearching = [[NSMutableDictionary alloc] init];
    [itemAttributesForSearching setObject: (id)kSecClassGenericPassword
                                   forKey: (id)kSecClass];
    [itemAttributesForSearching setObject: (id)(CFDataRef) [userName dataUsingEncoding:NSUTF8StringEncoding]
                                   forKey: (id)kSecAttrAccount];
    [itemAttributesForSearching setObject: (id)kCFBooleanTrue forKey:(id) kSecReturnData];
    
    @try {
        NSData *passwordData = nil;
        if (SecItemCopyMatching((CFDictionaryRef) itemAttributesForSearching, (CFTypeRef *) &passwordData) == noErr) {
            return [[[NSString alloc] initWithBytes: [passwordData bytes] length: [passwordData length]
                                           encoding: NSUTF8StringEncoding] autorelease];
        }
        else {
            return nil;
        }
    }
    @finally {
        [itemAttributesForSearching release];
    }
    
}

@end
