//
//  QueryEndPoint.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 31/01/2010.
//  Copyright 2010 ILRT, University of Bristol. All rights reserved.
//

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
    
    NSURL *url = [NSURL URLWithString:[endPoint endPointURL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60];
    
    NSString *query = [NSString stringWithFormat:@"%@=%@", [endPoint queryParamName],
                       [sparql stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:[endPoint httpMethod]];
    [request setValue:[NSString stringWithFormat:@"%d", 
                       [query length]] forHTTPHeaderField:CONTENT_LENGTH];
    [request setValue:APPLICATION_FORM forHTTPHeaderField:CONTENT_TYPE];  
    [request setValue:accept forHTTPHeaderField:HEADER_ACCEPT];
    [request setHTTPBody:data];

    
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
