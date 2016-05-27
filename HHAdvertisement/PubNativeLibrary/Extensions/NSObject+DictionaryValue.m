//
//  NSObject+DictionaryValue.m
//
//  Created by David Martin on 10/12/14.
//  Copyright (c) 2014 PubNative
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "NSObject+DictionaryValue.h"
#import <objc/runtime.h>

@implementation NSObject(DictionaryValue)

- (NSDictionary*)dictionaryValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for(NSInteger i = 0; i < propertyCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:propName
                                                    encoding:[NSString defaultCStringEncoding]];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [self performSelector:NSSelectorFromString(propertyName)];
#pragma clang diagnostic pop
        
        if (value && value != [NSNull null])
        {
            dict[propertyName] = value;
        }
    }
    
    return dict;
}

@end
