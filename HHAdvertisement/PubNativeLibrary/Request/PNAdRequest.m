//
//  PNAdRequest.m
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

#import "PNAdRequest.h"
#import "PNNativeAPIModel.h"
#import "PNNativeVideoAPIModel.h"
#import "NSObject+DictionaryValue.h"
#import "PNAdConstants.h"


@interface PNAdRequest()

@property (nonatomic, assign) PNAdRequestType               type;
@property (nonatomic, strong) PNAdRequestParameters         *parameters;
@property (nonatomic, strong) PNAdRequestCompletionBlock    completionBlock;
@property (nonatomic, strong) PNAPIModel                    *apiModel;

@end

@implementation PNAdRequest

#pragma mark NSObject

- (void)dealloc
{
    self.parameters = nil;
    self.completionBlock  = nil;
    self.apiModel = nil;
}

#pragma mark - PNAdRequest

#pragma mark public

+ (instancetype)request:(PNAdRequestType)type
         withParameters:(PNAdRequestParameters *)parameters
          andCompletion:(PNAdRequestCompletionBlock)completionBlock
{
    PNAdRequest *request = nil;
    
    if(parameters)
    {
        request = [[PNAdRequest alloc] init];
    
        request.type = type;
        request.parameters = parameters;
        request.completionBlock = completionBlock;
    }
    
    return request;
}

#pragma mark private

- (void)startRequest
{
    PNAPIModel  *apiModel   = nil;
    NSURL               *apiURL     = nil;
    
    switch (self.type)
    {
        case PNAdRequest_Native:
        {
            apiModel    = [PNNativeAPIModel alloc];
            apiURL      = [NSURL URLWithString:kPNAdConstantRequestAPINativeUrlString];
        }
        break;
            
        case PNAdRequest_Native_Video:
        {
            apiModel    = [PNNativeVideoAPIModel alloc];
            apiURL      = [NSURL URLWithString:kPNAdConstantRequestAPINativeVideoUrlString];
        }
        break;
    }
    
    if(apiModel && apiURL)
    {
        __weak PNAdRequest *weakSelf = self;
        [self.parameters fillWithDefaults];
        self.apiModel = [apiModel initWithURL:apiURL
                                       method:kPNAdConstantMethodGET
                                       params:[self.parameters dictionaryValue]
                                      headers:nil
                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                      timeout:kPNAdConstantRequestDefaultTimeout
                           andCompletionBlock:^(NSError *error)
                                                {
                                                    [weakSelf processAdsWithError:error];
                                                }];
    }
}

- (void)processAdsWithError:(NSError*)error
{
    if(error)
    {
        self.completionBlock(nil, error);
    }
    else if(![self.apiModel.status isEqualToString:kPNAdConstantAPIModelStatusSuccess])
    {
        NSString *errorString = [NSString stringWithFormat:@"Pubnative - request error: %@", self.apiModel.error_message];
        NSError *requestError = [NSError errorWithDomain:errorString code:1000 userInfo:nil];
        self.completionBlock(nil, requestError);
    }
    else if([self.apiModel.ads count] <= 0)
    {
        NSError *noAdsError = [NSError errorWithDomain:@"Pubnative - No ads to fill" code:1001 userInfo:nil];
        self.completionBlock(nil, noAdsError);
    }
    else
    {
        self.completionBlock(self.apiModel.ads, nil);
    }
}

@end
