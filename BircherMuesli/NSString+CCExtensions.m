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

- (BOOL)containsOnlyBinaryCharacters {
    NSRange range = [self rangeOfCharacterFromSet:[NSCharacterSet binaryCharacterSet]];
    BOOL status = range.length == [self length];
    return status;
}

- (BOOL)containsOnlyHexidecimalCharacters {
    NSRange range = [self rangeOfCharacterFromSet:[NSCharacterSet hexidecimalCharacterSet] options:NSCaseInsensitiveSearch];
    BOOL status = range.length == [self length];
    return status;
}

@end
