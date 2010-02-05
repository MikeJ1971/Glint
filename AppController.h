//
//  AppController.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 28/01/2010.
//  Copyright 2010 Mike Jones. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddEndPointController.h"

@interface AppController : NSObject <NSTableViewDataSource, AddEndPointDelegate> {

    IBOutlet NSWindow *mainWindow;

    NSTableView *endPointListTableView;             // displays registered endpoints
    NSTextView *queryTextView;                      // view for typing in the SPARQL query
    NSTextView *resultsTextView;                    // view for displaying results
    NSPopUpButton *resultsFormat;                   // list of formats to get results
    NSButton *runQueryButton;                       // fires the SPARQL query
    NSProgressIndicator *progressIndicator;
    NSTextField *urlIndicator ;
    
//    NSString *selectedEndPoint;                     // selected endpoint to query
    
    NSMutableArray *endPointList;                   // registered endpoints - dataSource for table

    AddEndPointController *addEndPointController;   // controller for adding endpoints
}

@property(retain,nonatomic) IBOutlet NSTableView *endPointListTableView;
@property(retain,nonatomic) IBOutlet NSTextView *queryTextView;
@property(retain,nonatomic) IBOutlet NSTextView *resultsTextView;
@property(retain,nonatomic) IBOutlet NSPopUpButton *resultsFormat;
@property(retain,nonatomic) IBOutlet NSButton *runQueryButton;
@property(retain,nonatomic) IBOutlet NSProgressIndicator *progressIndicator;
@property(retain,nonatomic) IBOutlet NSTextField *urlIndicator;

- (IBAction)runquery:(id)sender;

- (IBAction)addEndpoint:(id)sender;

- (IBAction)editEndpoint:(id)sender;

- (IBAction)removeEndpoint:(id)sender;

- (void)saveEndPointList;

- (NSString *)storagePath;

- (void)handleMainWindow:(id)sender;

@end
