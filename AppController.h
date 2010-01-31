//
//  AppController.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 28/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject <NSTableViewDataSource> {

    IBOutlet NSTableView *endPointListTableView;    // displays registered endpoints
    IBOutlet NSTextView *queryTextView;             // view for typing in the SPARQL query
    IBOutlet NSTextView *resultsTextView;           // view for displaying results
    IBOutlet NSPopUpButton *resultsFormat;          // list of formats to get results
    IBOutlet NSButton *runQueryButton;              // fires the SPARQL query
    
    NSString *selectedEndPoint;                     // selected endpoint to query
    
    NSMutableArray *endPointList;                   // registered endpoints - dataSource for table
}

@property(retain,nonatomic) IBOutlet NSTableView *endPointListTableView;
@property(retain,nonatomic) IBOutlet NSTextView *queryTextView;
@property(retain,nonatomic) IBOutlet NSTextView *resultsTextView;
@property(retain,nonatomic) IBOutlet NSPopUpButton *resultsFormat;
@property(retain,nonatomic) IBOutlet NSButton *runQueryButton;

- (IBAction)runquery:(id)sender;

- (int)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(int)row;

- (IBAction)addEndpoint:(id)sender;

- (IBAction)removeEndpoint:(id)sender;

@end
