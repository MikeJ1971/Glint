/*
 Copyright (c) 2010, University of Bristol
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1) Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2) Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 3) Neither the name of the University of Bristol nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

#import "QueryEndPoint.h"

#define RESULT_FORMAT_JSON          @"JSON";
#define RESULT_FORMAT_XML           @"XML";

#define APPLICATION_FORM            @"application/x-www-form-urlencoded"
#define APPLICATION_RESULTS_JSON    @"application/sparql-results+json";
#define APPLICATION_RESULTS_XML     @"application/sparql-results+xml"
#define CONTENT_LENGTH              @"Content-Length"
#define CONTENT_TYPE                @"Content-Type"
#define HEADER_ACCEPT               @"accept"

@implementation QueryEndPoint

- (id)init {
    
    if (![super init]) {
        return nil;
    }
    
    return self;
}

- (NSString *)queryEndPoint:(EndPoint *)endPoint withSparql:(NSString *)sparql
               resultsFormat:(NSString *)format {
    
    // what format do we need the results?
    
    NSString *accept;
    
    if ([format isEqualToString:@"JSON"]) {
        accept = APPLICATION_RESULTS_JSON;
    } else {
        accept = APPLICATION_RESULTS_XML;
    }    


    // create the request

    NSLog(@"Querying: %@", [endPoint endPointURL]);
    
    NSString *query = [NSString stringWithFormat:@"%@=%@", [endPoint queryParamName],
                       [sparql stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url;
    
    if ([[endPoint httpMethod] isEqualToString:@"GET"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [endPoint endPointURL], query]];
    } else {
        url = [NSURL URLWithString:[endPoint endPointURL]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60];
    
    if ([[endPoint httpMethod] isEqualToString:@"POST"]) {
        NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        [request setValue:[NSString stringWithFormat:@"%d", 
                           [query length]] forHTTPHeaderField:CONTENT_LENGTH];
        [request setValue:APPLICATION_FORM forHTTPHeaderField:CONTENT_TYPE];  
    }
    
    [request setHTTPMethod:[endPoint httpMethod]];
    [request setValue:accept forHTTPHeaderField:HEADER_ACCEPT];
    
    NSLog(@"Querying %@, with a connection timeout of %@ seconds", [endPoint endPointURL],
          [endPoint connectionTimeOut]);
    
    [request setTimeoutInterval:[[endPoint connectionTimeOut] floatValue]];

    
    // ----- Get the response
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    urlData = [NSURLConnection sendSynchronousRequest:request
                                    returningResponse:&response
                                                error:&error];
    
    if (!urlData) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
//        return;
    }
    
    return [[[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding] autorelease];
    
}

@end
