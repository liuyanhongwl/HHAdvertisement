//
//  PNAppModel.m
//
//  Created by Csongor Nagy on 04/06/14.
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

#import "PNAppModel.h"

@implementation PNAppModel

@synthesize name;
@synthesize platform;
@synthesize review;
@synthesize review_url;
@synthesize review_pros;
@synthesize review_cons;
@synthesize publisher;
@synthesize developer;
@synthesize version;
@synthesize size;
@synthesize age_rating;
@synthesize url_scheme;
@synthesize store_rating;
@synthesize store_description;
@synthesize store_url;
@synthesize store_id;
@synthesize store_categories;
@synthesize release_date;
@synthesize total_ratings;
@synthesize installs;
@synthesize category;
@synthesize sub_category;

#pragma mark - NSObject

- (void)dealloc
{
    self.name = nil;
    self.platform = nil;
    self.review = nil;
    self.review_url = nil;
    self.review_pros = nil;
    self.review_cons = nil;
    self.publisher = nil;
    self.developer = nil;
    self.version = nil;
    self.size = nil;
    self.age_rating = nil;
    self.url_scheme = nil;
    self.store_rating = nil;
    self.store_description = nil;
    self.store_url = nil;
    self.store_id = nil;
    self.store_categories = nil;
    self.release_date = nil;
    self.total_ratings = nil;
    self.installs = nil;
    self.category = nil;
    self.sub_category = nil;
}

#pragma mark - PNAppModel

@end