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

#import <Cocoa/Cocoa.h>
#import "AddEndPointController.h"
#import "SyntaxHighlighting.h"
#import "ResultsTableDelegate.h"

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
    
    NSArray *constructArray;
    NSArray *selectArray;
    
    int responseCode;
    
    NSURLConnection *aConnection;
    
    NSMutableString *textInProgress;
    NSString *bindingInProgress;
    
    NSMutableArray *columns;
    NSMutableDictionary *resultRow;
    NSMutableArray *resultRows;
    
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

- (void)saveEndPointList;

- (NSString *)storagePath;

- (void)handleMainWindow:(id)sender;

- (void)parseData:(NSData *)d;

@end
