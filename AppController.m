//
//  AppController.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 28/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import "AppController.h"
#import "EndPoint.h"

@implementation AppController

@synthesize sparqlEndPointList;
@synthesize queryTextView;
@synthesize resultsTextView;
@synthesize resultsFormat;
@synthesize runQueryButton;

- (id)init {
    
    if (![super init]) {
        return nil;
    }

    EndPoint *endPoint = [[EndPoint alloc] init];
    endPoint.endPointURL = @"http://services.data.gov.uk/analytics/sparql";
    
    endPointList = [[NSMutableArray alloc] init];
    [endPointList addObject:endPoint];
    [endPoint release];
    
    [sparqlEndPointList setDataSource:self];
    
    return self;
}


- (IBAction)runquery:(id)sender {
    
    // ----- Get the URL of the endpoint
    
    NSString *endPoint = @"http://services.data.gov.uk/analytics/sparql";
    
    // check that the endpoint has a value
    if ([endPoint length] == 0) {
        NSLog(@"The endpoint value is zero length");
        // TODO provide visual feedback that an endpoint is needed
        return;
    }

    
    // ----- Get the SPARQL query
    
    NSString *sparql = [[queryTextView textStorage] string];
    
    // check that the query has a value
    if ([sparql length] == 0) {
        NSLog(@"The sparql query value is zero length");
        // TODO provide visual feedback that an sparql is needed
        return;
    }

    
    NSString *accept;
        
    if ([[resultsFormat titleOfSelectedItem] isEqualToString:@"JSON"]) {
        accept = @"application/sparql-results+json";
    } else {
        accept = @"application/sparql-results+xml";
    }
    
    
    // ----- Create the request
        
    NSURL *url = [NSURL URLWithString:endPoint];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:60];

    NSString *query = [NSString stringWithFormat:@"query=%@",
                       [sparql stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d",
                       [query length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
    [request setValue:accept forHTTPHeaderField:@"accept"];
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
        return;
    }
    
    NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    
    [resultsTextView setString:responseString];
    
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSLog(@"%d endpoints listed", [endPointList count]);
    
    return [endPointList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row {
    
    EndPoint *endPoint = [endPointList objectAtIndex:row];
    NSLog(@"Endpoint: %@", endPoint.endPointURL);
    return endPoint.endPointURL;
}
- (void)dealloc {
    [super dealloc];
    [endPointList release];
}

@end
