/*
 Copyright (c) 2010, Mike Jones http://fairlypositive.com
 Copyright (c) 2010, University of Bristol http://www.bristol.ac.uk
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1) Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 
 2) Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 3) Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
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

// Author: Mike Jones (mike.a.jones@me.com)

#import "AppController.h"
#import "AppController+Private.h"
#import "EndPoint.h"
#import "AddEndPointController.h"

#define CONTENT_LENGTH                  @"Content-Length"
#define CONTENT_TYPE                    @"Content-Type"
#define HEADER_ACCEPT                   @"accept"
#define USER_AGENT                      @"User-Agent"

#define APPLICATION_FORM                @"application/x-www-form-urlencoded"
#define APPLICATION_RESULTS_JSON        @"application/sparql-results+json"
#define APPLICATION_RESULTS_XML         @"application/sparql-results+xml"
#define APPLICATION_RESULTS_RDF_XML     @"application/rdf+xml"
#define APPLICATION_RESULTS_N3          @"text/n3"
#define APPLICATION_RESULTS_TEXT        @"text/plain"
#define APPLICATION_RESULTS_TURTLE      @"application/x-turtle"

#define RESULT_FORMAT_TABLE             @"Table View"
#define RESULT_FORMAT_JSON              @"JSON"
#define RESULT_FORMAT_XML               @"XML"
#define RESULT_FORMAT_RDF_XML           @"RDF/XML"
#define RESULT_FORMAT_N3                @"N3"
#define RESULT_FORMAT_NTRIPLES          @"N-Triples"
#define RESULT_FORMAT_TURTLE            @"Turtle"

#define CLIENT_NAME                     @"Glint"

#define MAIN_WINDOW_MENU_ITEM_TAG       200
#define EDIT_ENDPOINT_TAG               300
#define EXPORT_RESULTS_TAG              400

#define TAB_VIEW_RESULTS                @"results"


@implementation AppController

@synthesize endPointListTableView;
@synthesize tabView;
@synthesize queryTextView;
@synthesize resultsTextView;
@synthesize resultsFormat;
@synthesize runQueryButton;
@synthesize cancelQueryButton;
@synthesize progressIndicator;

@synthesize tableScrollView;
@synthesize resultsTableView;

//@synthesize resultsTableDelegate;

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
    
    constructArray = [[NSArray alloc] initWithObjects:RESULT_FORMAT_RDF_XML, RESULT_FORMAT_NTRIPLES, 
                      RESULT_FORMAT_TURTLE, RESULT_FORMAT_N3, nil];
    selectArray = [[NSArray alloc] initWithObjects:RESULT_FORMAT_TABLE, RESULT_FORMAT_XML,
                   RESULT_FORMAT_JSON, nil];
    
    return self;
}

- (void)awakeFromNib {
    
    // make sure that the first endpoint in the list is selected by default
    if ([endPointList count] > 0) {
        NSIndexSet *defaultIndex = [[NSIndexSet alloc] initWithIndex:0];
        [endPointListTableView selectRowIndexes:defaultIndex byExtendingSelection:NO];
        [endPointListTableView scrollRowToVisible:0];
        [defaultIndex release];
    }
    
    syntaxHighlighting = [[SyntaxHighlighting alloc] init];
    
    [self addObserver:self forKeyPath:@"syntaxHighlighting.queryType" options:0 context:NULL];    
    [[queryTextView textStorage] setDelegate:syntaxHighlighting];
    [tabView selectTabViewItemWithIdentifier:@"sparql"];
    [tableScrollView setHidden:TRUE];
    
    resultsTableDelegate = [[ResultsTableDelegate alloc] init];
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    
    NSLog(@"Well, something was registered!");
    
    [resultsFormat removeAllItems];
    
    if (syntaxHighlighting.queryType == @"SELECT" || syntaxHighlighting.queryType == @"ASK") {
        NSLog(@"Observed a change to a select");
        [resultsFormat addItemsWithTitles:selectArray];
    }
    
    if (syntaxHighlighting.queryType == @"CONSTRUCT" || syntaxHighlighting.queryType == @"DESCRIBE") {
        NSLog(@"Observed a change to a construct");
        [resultsFormat addItemsWithTitles:constructArray];
    } 
    
    
}

- (void)dealloc {
    [super dealloc];
    [endPointList release];
    [addEndPointController release];
    //[caseInsensitiveKeywords release];
    //[whitespaceSet release];
    [syntaxHighlighting release];
    //[resultsTableDelegate release];
    [results release];
}

- (IBAction)runquery:(id)sender {
    
    NSLog(@"Run the query");
    
    startTime = [[NSDate alloc] init];
    
    // disable the run button and enable cancel
    [runQueryButton setEnabled:FALSE];
    [cancelQueryButton setEnabled:TRUE];
    
    // indicate that we are doing something ...
    [resultsTextView setString:@""];
    [progressIndicator startAnimation:self];
    
    // ----- Get the URL of the endpoint

    EndPoint *endPoint = nil;
    
    if ([endPointListTableView selectedRow] >= 0) {
        NSLog(@"selected row: %d", [endPointListTableView selectedRow]);
        endPoint = [endPointList objectAtIndex:[endPointListTableView selectedRow]];
    }
    
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
  
    // what format do we need the results?
    
    NSString *accept;
    
    if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_TABLE]) {
        accept = APPLICATION_RESULTS_XML;
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_JSON]) {
        accept = APPLICATION_RESULTS_JSON;
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_XML]) {
        accept = APPLICATION_RESULTS_XML;
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_RDF_XML]) {
        accept = APPLICATION_RESULTS_RDF_XML;
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_N3]) {
        accept = APPLICATION_RESULTS_N3;
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_NTRIPLES]) {
        accept = APPLICATION_RESULTS_TEXT;
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_TURTLE]) {
        accept = APPLICATION_RESULTS_TURTLE;
    } else {
        accept = APPLICATION_RESULTS_TEXT;
    }

    
    // create the request
    
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
    
    NSLog(@"Querying %@, with a connection timeout of %@ seconds, requesting content-type: %@",
          [endPoint endPointURL], [endPoint connectionTimeOut], accept);
    
    [request setTimeoutInterval:[[endPoint connectionTimeOut] floatValue]];
    [request setValue:[self userAgent] forHTTPHeaderField:USER_AGENT];
    
    aConnection = nil;
    aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    
    if (aConnection) {
        receivedData = [[[NSMutableData alloc] init] retain];
    } else {
        NSLog(@"Connection was nil ... should send some kind of dialog");
    }

}

- (IBAction)cancelQuery:(id)sender {
    
    NSLog(@"Request to cancel query");
    
    [cancelQueryButton setEnabled:FALSE];
    [aConnection cancel];
    [aConnection release];
    [progressIndicator stopAnimation:self];
    [runQueryButton setEnabled:TRUE];
}

- (IBAction)addEndpoint:(id)sender {
    
    if (!addEndPointController) {
        NSLog(@"Creating controller");
        addEndPointController = [[AddEndPointController alloc] init];
        [addEndPointController setDelegate:self];
    }

    [addEndPointController showWindow:self];
}


- (IBAction)editEndpoint:(id)sender {
    
    // we should have a selected row
    if ([endPointListTableView selectedRow] >= 0) {
        
        // create the controller if it doesn't exist
        if (!addEndPointController) {
            addEndPointController = [[AddEndPointController alloc] init];
            [addEndPointController setDelegate:self];
        }
        
        // in the controller set the endpoint and the index we need to upate
        addEndPointController.endPoint =[endPointList objectAtIndex:[endPointListTableView selectedRow]];
        addEndPointController.index = [endPointListTableView selectedRow];

        // display the window
        [addEndPointController showWindow:self];
        //[addEndPointController updateForm];
    }
}


- (IBAction)removeEndpoint:(id)sender {
    
    if ([endPointListTableView selectedRow] >= 0) {
        [endPointList removeObjectAtIndex:[endPointListTableView selectedRow]];
        [endPointListTableView reloadData];
        [self saveEndPointList];
    }
}

- (IBAction)exportResults:(id)sender {
    
    NSLog(@"exportResults called");
    
    NSSavePanel *exportPanel = [NSSavePanel savePanel];
    [exportPanel setCanCreateDirectories:YES];
    [exportPanel setTitle:@"Export results"];

    NSString *fileName;
    
    if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_TABLE]) {
        fileName = @"untitled.csv";
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_JSON]) {
        fileName = @"untitled.json";
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_N3] ||
               [[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_NTRIPLES]) {
        fileName = @"untitled.n3";
    } else if([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_RDF_XML] ||
              [[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_XML]) {
        fileName = @"untitled.xml";
    } else if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_TURTLE]) {
        fileName = @"untitled.ttl";
    } else {
        fileName = @"untiled.txt";
    }

    [exportPanel runModalForDirectory:nil file:fileName];
    
    if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_TABLE]) {
        NSLog(@"Here ....");
        [[resultsTableDelegate results] writeToURL:[exportPanel URL] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    } else {
        [results writeToURL:[exportPanel URL] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    
    
    
    NSLog(@"File: %@", [[exportPanel URL] description]);
    
}

-(void)addEndPointToArrayList:(EndPoint *)endPoint {
    
    if (endPoint != nil) {
        
        // add the new endpoint
        [endPointList addObject:endPoint];
        [endPointListTableView reloadData];
        
        // make sure the newly added endpoint is selected in the table
        NSIndexSet *defaultIndex = [[NSIndexSet alloc] initWithIndex:[endPointList count] - 1];
        [endPointListTableView selectRowIndexes:defaultIndex byExtendingSelection:NO];
        [endPointListTableView scrollRowToVisible:[endPointList count] - 1];
        [defaultIndex release];

        // save the new list
        [self saveEndPointList];
    }
}

- (void)replaceEndpointInArrayWith:(EndPoint *)endPoint atIndex:(NSInteger)index {
    
    if (endPoint != nil) {
        if (index >= 0) {
            [endPointList replaceObjectAtIndex:index withObject:endPoint];
            [self saveEndPointList];
        }
    }
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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/Glint";
    folder = [folder stringByExpandingTildeInPath];
    
    if (![fileManager fileExistsAtPath:folder]) {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES
                                attributes:nil error:nil];
    }
   
    NSString *dataFile = @"glint.data";
    
    return [folder stringByAppendingPathComponent:dataFile];
}

- (void)handleMainWindow:(id)sender {

    if (![mainWindow isVisible]) {
        [mainWindow makeKeyAndOrderFront:self];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {

    // toggle the menu item for opening / closing the main window
    if ([item tag] == MAIN_WINDOW_MENU_ITEM_TAG) {
        return ![mainWindow isVisible];
    }
    
    if ([item tag] == EDIT_ENDPOINT_TAG) {
        return [endPointListTableView selectedRow] >= 0;
    }

    if ([item tag] == EXPORT_RESULTS_TAG) {
        return results != nil;
    }
    
    return TRUE;
}



#pragma mark table view dataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSLog(@"%d endpoints listed", [endPointList count]);
    return [endPointList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    
    EndPoint *endPoint = [endPointList objectAtIndex:row];
    
    if (endPoint.name != nil) {
        return endPoint.name;
    } else {
        return endPoint.endPointURL;
    }

}


#pragma mark delegate methods for the NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    responseCode = httpResponse.statusCode;

    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [connection release];
    [receivedData release];
    receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], 
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
    
    [progressIndicator stopAnimation:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    endTime = [[NSDate alloc] init];
    
    NSTimeInterval diff = [endTime timeIntervalSinceDate:startTime];
    //NSTimeInterval diff = [startTime timeIntervalSinceNow];
    
    NSLog(@"Time: %f", diff);
    [startTime release];
    [endTime release];
    
    NSLog(@"connectionDidFinishLoading called");
    
    [progressIndicator stopAnimation:self];
    
    NSLog(@"connectionDidFinishLoading called");
    [connection release];

    NSLog(@"%d", responseCode);
    
    [results release];
    results = [[[NSString alloc] initWithData:receivedData
                                               encoding:NSUTF8StringEncoding] retain];
    
    if (responseCode == 400) {
        [self handle400];
    } else if (responseCode == 404) {
        [self handle404];
    } else {
        [self handle200];
    }
    
    [runQueryButton setEnabled:TRUE];
    [cancelQueryButton setEnabled:FALSE];
    
    [receivedData release];
    receivedData = nil;
}


- (NSString *) version {
    return @"0.6";
}

- (NSString *) userAgent {
    return [NSString stringWithFormat:@"%@/%@", CLIENT_NAME, [self version]];
}




@end

@implementation AppController(Private)




- (void)handle200 {

    if ([[resultsFormat titleOfSelectedItem] isEqualToString:RESULT_FORMAT_TABLE]) {
        [self displayResultsTable];
    } else {
        [self displayResults];
    }    
}

- (void)handle400 {
    [self displayResults];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Bad request!"
                                     defaultButton:nil alternateButton:nil 
                                       otherButton:nil
                         informativeTextWithFormat:@"The server returned the response code: 400 (Bad Request). This might have been caused by a syntax error in the SPARQL query."];
    [alert runModal];
    
}

- (void)handle404 {
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"SPARQL Endpoint not found!" 
                                     defaultButton:nil alternateButton:nil otherButton:nil
                         informativeTextWithFormat:@"The server returned the response code: 404 (Not Found). Please check the URL."];
    [alert runModal];
}

- (void)parseData:(NSData *)d {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:d];
    [parser setDelegate:resultsTableDelegate];
    [parser parse];
    [parser release];
}

- (void)displayResults {

    [tableScrollView setHidden:TRUE];    
    [resultsTextView setString:results];
    [[resultsTextView textStorage] setFont:[NSFont fontWithName:@"Monaco" size:10]];
    [tabView selectTabViewItemWithIdentifier:TAB_VIEW_RESULTS];
}

- (void)displayResultsTable {
    
    [self parseData:receivedData];
    [resultsTableView setDelegate:resultsTableDelegate];
    [resultsTableView setDataSource:resultsTableDelegate];
    [resultsTableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [resultsTableDelegate updateColumns:resultsTableView];
    [resultsTableView reloadData];
    [tableScrollView setHidden:FALSE];
    [tabView selectTabViewItemWithIdentifier:TAB_VIEW_RESULTS];
}

@end