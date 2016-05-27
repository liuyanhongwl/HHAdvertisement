//
// VastXMLParser.m
//
// Created by Csongor Nagy on 12/08/14.
// Copyright (c) 2014 PubNative
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VastXMLParser.h"
#import "PNAdConstants.h"

@interface VastXMLParser() <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableString                   *elementName;
@property (nonatomic, strong) NSMutableString                   *attributeName;

@end

@implementation VastXMLParser

- (void)dealloc
{
    self.ad = nil;
    self.elementName = nil;
    self.attributeName = nil;
}

static VastXMLParser* sharedParser = nil;

+ (VastXMLParser*)sharedParser
{
    @synchronized(self)
    {
        if (sharedParser == nil)
        {
            sharedParser                        = [[VastXMLParser alloc] init];
            sharedParser.ad                     = [[VastContainer alloc] init];
        }
    }
    
    return sharedParser;
}

- (void)callWithURLString:(NSString*)urlString andDelegate:(id<VastXMLParserDelegate>)delegate
{
    [VastXMLParser sharedParser].delegate = delegate;
    [VastXMLParser sharedParser].ad = [[VastContainer alloc] init];
    
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:kPNAdConstantMethodGET];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        [[NSURLSession sharedSession] dataTaskWithURL:<#(nonnull NSURL *)#> completionHandler:<#^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)completionHandler#> sendAsynchronousRequest:request
//                                           queue:[NSOperationQueue mainQueue]
//                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//         {
//             NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
//             NSString *contentType = [headers objectForKey:@"Content-Type"];
//             
//             if(error == nil &&
//                contentType &&
//                [contentType isEqualToString:@"application/xml"])
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
//                     [parser setDelegate:[VastXMLParser sharedParser]];
//                     [parser parse];
//                 });
//             }
//             else
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [[VastXMLParser sharedParser].delegate parserError:error];
//                 });
//             }
//         }];
    });
}

- (void)parseString:(NSString*)string andDelegate:(id<VastXMLParserDelegate>)delegate
{
    [VastXMLParser sharedParser].delegate = delegate;
    [VastXMLParser sharedParser].ad = [[VastContainer alloc] init];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:[VastXMLParser sharedParser]];
    [parser parse];
}



#pragma mark - NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict
{
    self.elementName = [[NSMutableString alloc] initWithString:elementName];
    
    if ([elementName isEqualToString:@"Ad"])
    {
        [self.ad setAdId:[attributeDict valueForKey:@"id"]];
    }
    
    if ([elementName isEqualToString:@"Tracking"])
    {
        self.attributeName = [[NSMutableString alloc] initWithString:[attributeDict valueForKey:@"event"]];
    }
    
    if ([elementName isEqualToString:@"Impression"])
    {
        self.attributeName = [[NSMutableString alloc] initWithString:[attributeDict valueForKey:@"id"]];
    }
    
    if ([elementName isEqualToString:@"MediaFile"])
    {
        [self.ad setMediaWidth:[attributeDict valueForKey:@"width"]];
        [self.ad setMediaHeight:[attributeDict valueForKey:@"height"]];
        [self.ad setMediaType:[attributeDict valueForKey:@"type"]];
        [self.ad setMediaDelivery:[attributeDict valueForKey:@"delivery"]];
        [self.ad setMediaScalable:[attributeDict valueForKey:@"scalable"]];
    }
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([self.elementName isEqualToString:@"Impression"] &&
        [self.attributeName isEqualToString:@"Impression"] &&
        [trimmedString length] > 0 &&
        !self.ad.impressionID)
    {
        [self.ad setImpressionID:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"AdSystem"] &&
        [trimmedString length] > 0)
    {
        [self.ad setAdSystem:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"AdTitle"] &&
        [trimmedString length] > 0)
    {
        [self.ad setAdTitle:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Description"] &&
        [trimmedString length] > 0)
    {
        if ([self.ad respondsToSelector:@selector(setAdDescription:)])
        {
            [self.ad setAdDescription:trimmedString];
        }
    }
    
    if ([self.elementName isEqualToString:@"Duration"] &&
        [trimmedString length] > 0)
    {
        [self.ad setDuration:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"MediaFile"] &&
        [trimmedString length] > 0)
    {
        [self.ad setMediaFile:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"creativeView"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingCreativeView:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"start"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingStart:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"firstQuartile"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingFirstQuartile:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"midpoint"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingMidpoint:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"thirdQuartile"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingThirdQuartile:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"complete"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingComplete:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"mute"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingMute:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"unmute"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingUnmute:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"pause"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingPause:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"Tracking"] &&
        [self.attributeName isEqualToString:@"fullscreen"] &&
        [trimmedString length] > 0)
    {
        [self.ad setTrackingFullscreen:trimmedString];
    }
    
    if ([self.elementName isEqualToString:@"ClickThrough"] &&
        [trimmedString length] > 0)
    {
        [self.ad setClickThrough:trimmedString];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [[VastXMLParser sharedParser].delegate parserReady:self.ad];
}

@end
