//
//  AppController.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 28/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import "AppController.h"


@implementation AppController

@synthesize sparqlEndPointField;
@synthesize runQueryButton;
@synthesize queryTextView;
@synthesize resultsTextView;

- (IBAction)runquery:(id)sender {
    
    // ----- Get the URL of the endpoint
    
    NSString *endPoint = [sparqlEndPointField stringValue];
    
    // check that the endpoint has a value
    if ([endPoint length] == 0) {
        NSLog(@"The endpoint value is zero length");
        // TODO provide visual feedback that an endpoint is needed
        return;
    }

    NSLog(@"We have the endpoint: %@", endPoint);

    
    // ----- Get the SPARQL query
    
    NSString *sparql = [[queryTextView textStorage] string];
    
    // check that the query has a value
    if ([sparql length] == 0) {
        NSLog(@"The sparql query value is zero length");
        // TODO provide visual feedback that an sparql is needed
        return;
    }
    
    NSLog(@"We have the sparql query: %@", sparql);

    
    // ----- Create the request

    NSString *urlString = [NSString stringWithFormat:@"%@?query=%@", endPoint,
                           [sparql stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:60];

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
        return;
    }
    
    NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Response:\n%@", responseString);
    
    [resultsTextView setString:responseString];
    
}

@end
