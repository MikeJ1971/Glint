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

#import <Cocoa/Cocoa.h>
#import "AddEndPointController.h"
#import "SyntaxHighlighting.h"
#import "ResultsTableDelegate.h"

@interface AppController : NSObject <AddEndPointDelegate, NSTableViewDataSource> {

    // ---- user Interface components
    
    IBOutlet NSWindow *mainWindow;                  // application window
    NSTableView *endPointListTableView;             // displays registered endpoints
    NSTabView *tabView;                             // encapsulates SPARQL and results
    NSTextView *queryTextView;                      // view for typing in the SPARQL query
    NSTextView *resultsTextView;                    // view for displaying results
    NSPopUpButton *resultsFormat;                   // list of formats to get results
    NSButton *runQueryButton;                       // fires the SPARQL query
    NSButton *cancelQueryButton;                    // cancel the SPARQL query
    NSProgressIndicator *progressIndicator;         // indicates a query is in progress
    NSScrollView *tableScrollView;                  // encapsualtes the results tableView
    NSTableView *resultsTableView;                  // holds the results of a SELECT query

    // ---- controllers

    AddEndPointController *addEndPointController;   // controller for adding endpoints
    
    // ---- delegates and utility classes
    
    ResultsTableDelegate *resultsTableDelegate;     // handles tabular views of the data
    SyntaxHighlighting *syntaxHighlighting;         // syntax highlighting for SPARQL queries

    // ---- data sources and structures
    
    NSMutableArray *endPointList;                   // registered endpoints - dataSource for table
    NSArray *constructArray, *selectArray;          // will hold result formats for queries
    NSMutableData *receivedData;                    // data received from an endpoint
    NSString *results;                              // string representation of data from endpoint

    // ---- connection and response handling
    
    NSURLConnection *aConnection;                   // connection to SPARQL endpoints
    int responseCode;                               // HTTP response code from an endpoint
    NSDate *startTime, *endTime;                    // track query execution time
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
@property(retain,nonatomic) IBOutlet NSTableView *resultsTableView;

// ---- handling queries and results

- (IBAction)runquery:(id)sender;
- (IBAction)cancelQuery:(id)sender;
- (IBAction)exportResults:(id)sender;

// ---- SPARQL endpoint management

- (IBAction)addEndpoint:(id)sender;
- (IBAction)editEndpoint:(id)sender;
- (IBAction)removeEndpoint:(id)sender;

// ---- utility methods

- (NSString *)version;
- (NSString *)userAgent;
- (void)saveEndPointList;
- (NSString *)storagePath;
- (void)handleMainWindow:(id)sender;
- (void)parseData:(NSData *)d;

@end
