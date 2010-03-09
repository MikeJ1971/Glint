//
//  ResultsTableDelegate.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 08/03/2010.
//  Copyright 2010 ILRT, University of Bristol. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ResultsTableDelegate : NSObject {

    NSMutableArray *columns;
    NSMutableArray *results;
    
    NSMutableDictionary *row;
    NSMutableString *textInProgress;
    NSString *bindingInProgress;
}

- (void)updateColumns:(NSTableView *)aTableView;

@end
