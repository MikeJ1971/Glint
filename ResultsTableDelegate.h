//
//  ResultsTableDelegate.h
//  LinkedDataViewer
//
//  Created by Mike Jones on 08/03/2010.
//  Copyright 2010 ILRT, University of Bristol. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ResultsTableDelegate : NSObject {

    NSArray *columns;
    NSMutableArray *results;
}

@property(retain,nonatomic) NSArray *columns;
@property(retain,nonatomic) NSMutableArray *results;

- (void)updateColumns:(NSTableView *)aTableView;

- (void)addResult:(NSDictionary *)aResult;

- (NSInteger)rowCount;

@end
