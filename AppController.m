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

// Author: Mike Jones (mike.a.jones@bristol.ac.uk)

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

#define MAIN_WINDOW_MENU_ITEM_TAG   200
#define EDIT_ENDPOINT_TAG           300

@implementation AppController

@synthesize endPointListTableView;
@synthesize queryTextView;
@synthesize resultsTextView;
@synthesize resultsFormat;
@synthesize runQueryButton;
@synthesize progressIndicator;
@synthesize urlIndicator;

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

- (void)awakeFromNib {
    
    // make sure that the first endpoint in the list is selected by default
    if ([endPointList count] > 0) {
        NSIndexSet *defaultIndex = [[NSIndexSet alloc] initWithIndex:0];
        [endPointListTableView selectRowIndexes:defaultIndex byExtendingSelection:NO];
        [endPointListTableView scrollRowToVisible:0];
        [defaultIndex release];
    }
    
    syntaxHighlighting = [[SyntaxHighlighting alloc] init];
    
    [[queryTextView textStorage] setDelegate:syntaxHighlighting];
    
}

- (void)dealloc {
    [super dealloc];
    [endPointList release];
    [addEndPointController release];
    //[caseInsensitiveKeywords release];
    //[whitespaceSet release];
    [syntaxHighlighting release];
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

    
    
    [progressIndicator startAnimation:self];
    //[urlIndicator setStringValue:[NSString stringWithFormat:@"Querying %@", [endPoint endPointURL]]];

    QueryEndPoint *query = [[QueryEndPoint alloc] init];
    NSString *results = [query queryEndPoint:endPoint withSparql:sparql 
                               resultsFormat:[resultsFormat titleOfSelectedItem]];
    [resultsTextView setString:results];
    //[urlIndicator setStringValue:@""];
    [progressIndicator stopAnimation:self];
    
    [query release];
    
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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"LinkedDataViewer.bin"];
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
    return endPoint.endPointURL;
}

@end