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
#import "AddEndPointController.h"

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

    // create the list from the archived objects
    endPointList = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self storagePath]] retain];
    
    // if the list is nil, nothing is saved, so create it
    if (endPointList == nil) {
        endPointList = [[NSMutableArray alloc] init];
    }

    // display the list in the table
    [endPointListTableView setDataSource:self];
    
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
    
    if (!addEndPointController) {
        NSLog(@"Creating controller");
        addEndPointController = [[AddEndPointController alloc] init];
        [addEndPointController setDelegate:self];
    }
    
    NSLog(@"Display the window");
    [addEndPointController showWindow:self];
    
}

- (IBAction)removeEndpoint:(id)sender {
    
    NSLog(@"Should remove something ..."); 
    
    if ([endPointListTableView selectedRow] >= 0) {
        NSLog(@"selected row to remove: %d", [endPointListTableView selectedRow]);
        [endPointList removeObjectAtIndex:[endPointListTableView selectedRow]];
        [endPointListTableView reloadData];
        [self saveEndPointList];
    }
    
}

-(void)addEndPoint:(EndPoint *)endPoint {
    
    [endPointList addObject:endPoint];
    [endPointListTableView reloadData];
    [self saveEndPointList];
}

- (void)saveEndPointList {

    // save to disk

    BOOL result = [NSKeyedArchiver archiveRootObject:endPointList
                                              toFile:[self storagePath]];
    if (result == YES) {
        NSLog(@"Successfully saved endpoints");
    } else {
        NSLog(@"Failed to save endpoints");
    }
    
}

- (NSString *)storagePath {

    // calculate the paths ...
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"LinkedDataViewer.bin"];
}

- (void)dealloc {
    [super dealloc];
    [endPointList release];
    [addEndPointController release];
}

@end