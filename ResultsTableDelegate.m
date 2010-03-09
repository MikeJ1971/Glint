//
//  ResultsTableDelegate.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 08/03/2010.
//  Copyright 2010 ILRT, University of Bristol. All rights reserved.
//

#import "ResultsTableDelegate.h"


@implementation ResultsTableDelegate

@synthesize columns;
@synthesize results;

- (void)updateColumns:(NSTableView *)aTableView {

    NSLog(@"Existing columns: %d", [[aTableView tableColumns] count]);
    
    // remove existing columns
    for (NSTableColumn *tcr in [aTableView tableColumns]) {

        NSLog(@"In the loop for removing a header; identifier: %@", [tcr identifier]);

        [aTableView removeTableColumn:tcr];
    }
    
    NSLog(@"New columns: %d", [columns count]);
    
    // add the new columns
    for (NSString *identifier in columns) {
        NSTableColumn* tc = [[NSTableColumn alloc] initWithIdentifier:identifier];
        [[tc headerCell] setStringValue:identifier];
        [aTableView addTableColumn:tc];
        [tc release];
    }
    
    [aTableView setColumnAutoresizingStyle:NSTableViewFirstColumnOnlyAutoresizingStyle];
    
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex {
    NSLog(@"yes!");
    return [[results objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    NSLog(@"Cols: %d", [[self columns] count]);
    NSLog(@"Rows: %d", [self rowCount]);
    return [results count];
}

- (void)addResult:(NSDictionary *)aResult {
    NSLog(@"Adding object with size: %d", [aResult count]);
    [results addObject:aResult];
}

- (NSInteger)rowCount {
    return [results count];
}

@end
