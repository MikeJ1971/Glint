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

// Author: Mike Jones (mike.a.jones@bristol.ac.uk)

#import <Cocoa/Cocoa.h>
#import "AddEndPointController.h"
#import "SyntaxHighlighting.h"
#import "ResultsTableDelegate.h"

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
//#define APPLICATION_RESULTS_TURTLE      @"text/turtle"
#define APPLICATION_RESULTS_TURTLE      @"application/x-turtle"

#define RESULT_FORMAT_TABLE             @"Table View"
#define RESULT_FORMAT_JSON              @"JSON"
#define RESULT_FORMAT_XML               @"XML"
#define RESULT_FORMAT_RDF_XML           @"RDF/XML"
#define RESULT_FORMAT_N3                @"N3"
#define RESULT_FORMAT_NTRIPLES          @"N-Triples"
#define RESULT_FORMAT_TURTLE            @"Turtle"

#define USER_AGENT_NAME                 @"LinkedDataViewer/0.4"

#define MAIN_WINDOW_MENU_ITEM_TAG       200
#define EDIT_ENDPOINT_TAG               300
#define EXPORT_RESULTS_TAG              400

@interface AppController : NSObject <AddEndPointDelegate> {

    IBOutlet NSWindow *mainWindow;

    NSTableView *endPointListTableView;             // displays registered endpoints
    NSTabView *tabView;                             // encapsulates SPARQL and results
    NSTextView *queryTextView;                      // view for typing in the SPARQL query
    NSTextView *resultsTextView;                    // view for displaying results
    NSPopUpButton *resultsFormat;                   // list of formats to get results
    NSButton *runQueryButton;                       // fires the SPARQL query
    NSButton *cancelQueryButton;                    // cancel the SPARQL query
    NSProgressIndicator *progressIndicator;         // indicates a query is in progress
    
    NSScrollView *tableScrollView;
    NSTableView *tableView;
    
    NSMutableArray *endPointList;                   // registered endpoints - dataSource for table

    SyntaxHighlighting *syntaxHighlighting;
    AddEndPointController *addEndPointController;   // controller for adding endpoints
    
    NSMutableData *receivedData;
    NSString *results;
    
    NSArray *constructArray;
    NSArray *selectArray;
    
    int responseCode;
    
    NSURLConnection *aConnection;
    
//    NSMutableString *textInProgress;
//    NSString *bindingInProgress;
    
//    NSMutableArray *columns;
//    NSMutableDictionary *resultRow;
//    NSMutableArray *resultRows;
    
    NSDate *startTime;
    NSDate *endTime;
    
    ResultsTableDelegate *resultsTableDelegate;
    
    
}

@property(retain,nonatomic) IBOutlet NSTableView *endPointListTableView;
@property(retain,nonatomic) IBOutlet NSTabView *tabView;
@property(retain,nonatomic) IBOutlet NSTextView *queryTextView;
@property(retain,nonatomic) IBOutlet NSTextView *resultsTextView;
@property(retain,nonatomic) IBOutlet NSPopUpButton *resultsFormat;
@property(retain,nonatomic) IBOutlet NSButton *runQueryButton;
@property(retain,nonatomic) IBOutlet NSButton *cancelQueryButton;
@property(retain,nonatomic) IBOutlet NSProgressIndicator *progressIndicator;

@property(retain,nonatomic) IBOutlet NSScrollView *tableScrollView;
@property(retain,nonatomic) IBOutlet NSTableView *tableView;

//@property(retain,nonatomic) ResultsTableDelegate *resultsTableDelegate;

- (IBAction)runquery:(id)sender;

- (IBAction)cancelQuery:(id)sender;

- (IBAction)addEndpoint:(id)sender;

- (IBAction)editEndpoint:(id)sender;

- (IBAction)removeEndpoint:(id)sender;

- (IBAction)exportResults:(id)sender;

- (void)saveEndPointList;

- (NSString *)storagePath;

- (void)handleMainWindow:(id)sender;

- (void)parseData:(NSData *)d;


@end
