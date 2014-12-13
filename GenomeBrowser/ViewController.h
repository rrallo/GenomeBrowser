//
//  ViewController.h
//  GenomeBrowser
//
//  Created by Rodrigo Rallo on 12/9/14.
//  Copyright (c) 2014 Team3. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) NSMutableArray* data;

@property (weak) IBOutlet NSTableView *entryTableView;
@property (weak) IBOutlet NSTableView *infoTableView;

@property (weak) IBOutlet NSTableColumn *infoColumn;
@property (weak) IBOutlet NSTableColumn *valueColumn;
@property (weak) IBOutlet NSTableColumn *entryColumn;

@property (strong) NSMutableArray* infoFields;
@property (weak) IBOutlet NSSearchField *searchField;


@property (strong, nonatomic) NSMutableArray* packetData;
//@property (unsafe_unretained) IBOutlet NSTextView *descriptionTextView;

@property (weak) IBOutlet NSTextFieldCell *summaryLabel;

@property (weak) IBOutlet NSScrollView *backgroundEntryTableView;
@property (weak) IBOutlet NSScrollView *backgroundInfoTableView;
@property (weak) IBOutlet WebView *snpWebview;
@property (weak) IBOutlet WebView *omimWebview;



@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic) int webViewLoads_;
@property (nonatomic) int totalWebViewPluses;
@property (nonatomic) int totalWebViewMinuses;
@property (nonatomic) int totalDifferenceInLoads;

@property (weak) IBOutlet NSSegmentedControl *webSegmentedControl;
@property (strong, nonatomic) NSURL* currentSNPURL;
@property (strong, nonatomic) NSURL* currentOMIMURL;
@property (weak) IBOutlet NSButton *check;

@end

