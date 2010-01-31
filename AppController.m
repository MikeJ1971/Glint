//
//  AppController.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 28/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import "AppController.h"
#import "EndPoint.h"
#import "QueryEndPoint.h"

#define APPLICATION_FORM            @"application/x-www-form-urlencoded"
#define APPLICATION_RESULTS_JSON    @"application/sparql-results+json";
#define APPLICATION_RESULTS_XML     @"application/sparql-results+xml"
#define CONTENT_LENGTH              @"Content-Length"
#define CONTENT_TYPE                @"Content-Type"
#define HEADER_ACCEPT               @"accept"

@implementation AppController

@synthesize endPointListTableView;
@synthesize queryTextView;
@synthesize resultsTextView;
@synthesize resultsFormat;
@synthesize runQueryButton;

- (id)init {
    
    if (![super init]) {
        return nil;
    }

    EndPoint *endPoint1 = [[EndPoint alloc] init];
    endPoint1.endPointURL = @"http://services.data.gov.uk/analytics/sparql";
    endPoint1.queryParamName = @"query";
    endPoint1.httpMethod = @"POST";

    EndPoint *endPoint2 = [[EndPoint alloc] init];
    endPoint2.endPointURL = @"http://services.data.gov.uk/education/sparql";
    endPoint2.queryParamName = @"query";
    endPoint2.httpMethod = @"POST";
    
    EndPoint *endPoint3 = [[EndPoint alloc] init];
    endPoint3.endPointURL = @"http://services.data.gov.uk/environment/sparql";
    endPoint3.queryParamName = @"query";
    endPoint3.httpMethod = @"POST";
    
    EndPoint *endPoint4 = [[EndPoint alloc] init];
    endPoint4.endPointURL = @"http://services.data.gov.uk/finance/sparql";
    endPoint4.queryParamName = @"query";
    endPoint4.httpMethod = @"POST";
    
    EndPoint *endPoint5 = [[EndPoint alloc] init];
    endPoint5.endPointURL = @"http://services.data.gov.uk/transport/sparql";
    endPoint5.queryParamName = @"query";
    endPoint5.httpMethod = @"POST";
    
    EndPoint *endPoint6 = [[EndPoint alloc] init];
    endPoint6.endPointURL = @"http://services.data.gov.uk/notices/sparql";
    endPoint6.queryParamName = @"query";
    endPoint6.httpMethod = @"POST";
    
    
    endPointList = [[NSMutableArray alloc] init];
    [endPointList addObject:endPoint1];
    [endPointList addObject:endPoint2];
    [endPointList addObject:endPoint3];
    [endPointList addObject:endPoint4];
    [endPointList addObject:endPoint5];
    [endPointList addObject:endPoint6];
    
    [endPoint1 release];
    [endPoint2 release];
    [endPoint3 release];
    [endPoint4 release];
    [endPoint5 release];
    [endPoint6 release];
    
    [endPointListTableView setDataSource:self];
    
    selectedEndPoint = [[NSString alloc] init];
    
    return self;
}


- (IBAction)runquery:(id)sender {
    
    // ----- Get the URL of the endpoint

    EndPoint *endPoint = nil;
    
    if ([endPointListTableView selectedRow] >= 0) {
        NSLog(@"selected row: %d", [endPointListTableView selectedRow]);
        endPoint = [endPointList objectAtIndex:[endPointListTableView selectedRow]];
    }
    
    NSLog(@"Querying: %@", [endPoint endPointURL]);
    
    // check that the endpoint has a value
    if ([[endPoint endPointURL] length] == 0) {
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
    
    QueryEndPoint *query = [[QueryEndPoint alloc] init];
    NSString *results = [query queryEndPoint:endPoint withSparql:sparql 
                               resultsFormat:[resultsFormat titleOfSelectedItem]];
    [resultsTextView setString:results];
    
    [query release];
    
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSLog(@"%d endpoints listed", [endPointList count]);
    return [endPointList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row {
    
    EndPoint *endPoint = [endPointList objectAtIndex:row];
    return endPoint.endPointURL;
}

- (IBAction)addEndpoint:(id)sender {
    
    NSLog(@"Should add something ...");
}

- (IBAction)removeEndpoint:(id)sender {
    
    NSLog(@"Should remove something ..."); 
    
    if ([endPointListTableView selectedRow] >= 0) {
        NSLog(@"selected row to remove: %d", [endPointListTableView selectedRow]);
        [endPointList removeObjectAtIndex:[endPointListTableView selectedRow]];
        [endPointListTableView reloadData];
    }
    
}

- (void)dealloc {
    [super dealloc];
    [endPointList release];
}

@end
