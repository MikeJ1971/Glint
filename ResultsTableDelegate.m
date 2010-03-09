//
//  ResultsTableDelegate.m
//  LinkedDataViewer
//
//  Created by Mike Jones on 08/03/2010.
//  Copyright 2010 ILRT, University of Bristol. All rights reserved.
//

#import "ResultsTableDelegate.h"

#define HEAD_ELEMENT            @"head"
#define VARIABLE_ELEMENT        @"variable"
#define RESULTS_ELEMENT         @"results"
#define RESULT_ELEMENT          @"result"

#define NAME_ATTRIBUTE          @"name"

#define URI_TYPE                @"uri"
#define LITERAL_TYPE            @"literal"
#define BNODE_TYPE              @"bnode"

@implementation ResultsTableDelegate

- (id)init {
    
    if (![super init]) {
        return nil;
    }
    
    columns = [[[NSMutableArray alloc] init] retain];
    results = [[[NSMutableArray alloc] init] retain];
    
    return self;
}

- (void)dealloc {

    [super dealloc];
    [columns release];
    [results release];
}

- (void)updateColumns:(NSTableView *)aTableView {
    
    // we iterate over the columns to get the identifies and add them to a tempory array;
    // we can then iterate over this temporary array to find the identifiers of columns 
    // that we want to remove from the table - removing columns while iterating over the 
    // columns array causes issues about mutability
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];  // will hold the identifiers
    
    for (NSTableColumn *col in [aTableView tableColumns]) {
        [temp addObject:[col identifier]];
    }    

    // remove columns based on the identifiers
    for (NSString *identifier in temp) {
        [aTableView removeTableColumn:[aTableView tableColumnWithIdentifier:identifier]];
    } 
    
    // add the new columns
    for (NSString *identifier in columns) {
        NSTableColumn* tc = [[NSTableColumn alloc] initWithIdentifier:identifier];
        [[tc headerCell] setStringValue:identifier];
        [tc setWidth:400];
        [aTableView addTableColumn:tc];
        [tc release];
    }
    
    [temp release];
}


#pragma mark XML SAX delegate calls

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {

    // ---------- dealing with the head
    
    // clear the columns when we hit the "head" element
    if ([elementName isEqualToString:HEAD_ELEMENT]) {
        [columns removeAllObjects];
    }

    // get the variable values
    if ([elementName isEqualToString:VARIABLE_ELEMENT]) {
        [columns addObject:[attributeDict objectForKey:NAME_ATTRIBUTE]];
    }
    
    // ---------- dealing with the results
    
    // clear the results when we hit the "results" element
    if ([elementName isEqualToString:RESULTS_ELEMENT]) {
        NSLog(@"Clearing results array");
        [results removeAllObjects];
    }    
    
    // we have entered a result - create a dictionary to hold it
    if ([elementName isEqualToString:@"result"]) {
        row = [[NSMutableDictionary alloc] init];
    }

    // keep track of the binding - we'll use it as a key in the row dictionary
    if ([elementName isEqualToString:@"binding"]) {
        bindingInProgress = [[[NSString alloc]
                              initWithString:[attributeDict objectForKey:NAME_ATTRIBUTE]] retain];
    }

    // value we are interested in - initiated the String to hold the text
    if ([elementName isEqualToString:URI_TYPE] || [elementName isEqualToString:LITERAL_TYPE] ||
        [elementName isEqualToString:BNODE_TYPE]) {
        
        textInProgress = [[NSMutableString alloc] init];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // end of the value, so add collected data to the row dictionary
    if ([elementName isEqualToString:URI_TYPE] || [elementName isEqualToString:LITERAL_TYPE] ||
        [elementName isEqualToString:BNODE_TYPE]) {
        
        [row setObject:textInProgress forKey:bindingInProgress];

        [textInProgress release];
        textInProgress = nil;
        
        [bindingInProgress release];
        bindingInProgress = nil;
    }
    
    // end of a results, so add the row dictionary to the results array
    if ([elementName isEqualToString:RESULT_ELEMENT]) {
        [results addObject:row];
        [row release];
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [textInProgress appendString:string];
}


#pragma mark XML SAX delegate calls

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex {

    return [[results objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

    return [results count];
}

@end
