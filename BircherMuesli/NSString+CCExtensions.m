//
//  NSString+CCExtensions.m
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 8 Aug 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "NSString+CCExtensions.h"

@interface NSCharacterSet(CCExtensions)
+ (id)binaryCharacterSet;
+ (id)hexidecimalCharacterSet;
@end
@implementation NSCharacterSet(CCExtensions)
+ (id)binaryCharacterSet {
#if 0
    static dispatch_once_t binarypred;
    static id sharedBinaryCharacterSet = nil;

    dispatch_once(&binarypred, ^{
        sharedBinaryCharacterSet = [[self class] characterSetWithCharactersInString:@"01"];
    });

    return sharedBinaryCharacterSet;
#else
    return [[self class] characterSetWithCharactersInString:@"01"];
#endif
}
+ (id)hexidecimalCharacterSet {
#if 0
    static dispatch_once_t hexPred;
    static id sharedHexidecimalCharacterSet = nil;

    dispatch_once(&hexPred, ^{
        sharedHexidecimalCharacterSet = [[self class] characterSetWithCharactersInString:@"0123456789ABCDEF"];
    });

    return sharedHexidecimalCharacterSet;
#else
    return [[self class] characterSetWithCharactersInString:@"0123456789ABCDEF"];
#endif
}
@end

#pragma mark -

@implementation NSString(CCExtensions)

- (BOOL)isLikleyBinaryString {
    BOOL status = [[self stringByTrimmingCharactersInSet:[NSCharacterSet binaryCharacterSet]] isEqualToString:@""];
    return status;
}

- (BOOL)isLikleyHexString {
    BOOL hasHexPrefix = [[self lowercaseString] hasPrefix:@"0x"];
    NSString* string = hasHexPrefix ? [self substringWithRange:NSMakeRange(2, self.length-2)] : self;
    BOOL status = [[[string uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet hexidecimalCharacterSet]] isEqualToString:@""];
    return status;
}

- (NSData*)dataForBinaryValue {
    return nil;
}

- (NSData*)dataForHexValue {
    NSMutableData* data = [NSMutableData data];
    if (self.length % 2) {
        return nil;
    }

    for (NSUInteger start = 0; start < self.length; start+=2) {
        NSString* byteString = [self substringWithRange:NSMakeRange(start, 2)];
        NSScanner* scanner = [NSScanner scannerWithString:byteString];
        unsigned int value = 0;
        [scanner scanHexInt:&value];
        [data appendBytes:&value length:1];
    }

    return (NSData*)data;
}

@end
