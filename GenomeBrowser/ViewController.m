//
//  ViewController.m
//  GenomeBrowser
//
//  Created by Rodrigo Rallo on 12/9/14.
//  Copyright (c) 2014 Team3. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "GenomePacket.h"

@implementation ViewController{
    JSContext *_context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Leave this file name unless you want to read a different specified VCF file in JSON format, within this packaged bundle.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"snpediaMap" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    //Initialize the Packet array
    self.packetData =  [[NSMutableArray alloc] init];
    
    //Load put JSON entries into the Genome Packet array
    for (NSDictionary *d in json) {
        GenomePacket *g = [[GenomePacket alloc] initWithDictionary:[d mutableCopy]];
        [self.packetData addObject:g];
    }
    
    //sort using priority
    NSSortDescriptor *priorityDescriptor;
    priorityDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority"
                                                 ascending:NO];
    
    NSArray *sortedArray;
    NSArray *sortDescriptors = [NSArray arrayWithObject:priorityDescriptor];
    sortedArray = [self.packetData sortedArrayUsingDescriptors:sortDescriptors];
    self.packetData = [sortedArray mutableCopy];
    
    self.snpWebview.resourceLoadDelegate = self;
    
    //Webview setup
    self.webSegmentedControl.selectedSegment = 0;
    self.snpWebview.hidden = NO;
    self.omimWebview.hidden = YES;
    
    [self.webSegmentedControl setAction:@selector(handleSegmentedControlValueChanged:)];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}


//Leave constant unless you want to modify cell look and feel.
- (CGFloat)tableView:(NSTableView *)tableView
         heightOfRow:(NSInteger)row{
    return 26.0f;
}


//Returns the number of packets read from the text file.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (self.entryTableView == tableView) {
        return [self.packetData count];
    }
    if (self.infoTableView == tableView) {
        return [[[self selectedEntry]uniqueFields]count];
    }
    return [self.packetData count];
}



/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    //Tableview with all key/value pair information for given entry.
    if(tableView == self.infoTableView){
        if (tableColumn == self.infoColumn) {
            
            if (self.infoFields.count > row) {
                return self.infoFields[row];
            }
        }
        
        if (tableColumn == self.valueColumn) {
            GenomePacket *g = [self selectedEntry];
            if (g != nil) {
                NSString *key = self.infoFields[row];
                if (![key isEqualToString:@"description"] && ![key isEqualToString:@"phenotype"]) {
                    NSString *ret = g.dict[key];
                    return ret;
                }
                
            }
        }
    }

    //Leftside tableview, list of all entries
    if (tableView == self.entryTableView) {
        if (tableColumn == self.entryColumn) {
            GenomePacket *entry = [self.packetData objectAtIndex:row];
            return entry.rsid;
        }
    }
    return @"N/A";
}

//Handle events of any selection changes by user.
//This gets called anytime the user scrolls to a new entry too.
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if (self.entryTableView == aNotification.object) {
        
        GenomePacket *selectedEntry = [self selectedEntry];
        // Update info
        [self setDetailInfo:selectedEntry];
    }
}

//Asks the VC for the current selected GenomePacket entry
-(GenomePacket*)selectedEntry
{
    NSInteger selectedRow = [self.entryTableView selectedRow];
    if( selectedRow >=0 && self.packetData.count > selectedRow )
    {
        GenomePacket *selectedEntry = [self.packetData objectAtIndex:selectedRow];
        return selectedEntry;
    }
    return nil;
}

-(void)setDetailInfo:(GenomePacket*)data
{
    NSString    *rsid = @" ";
    NSString     *mim = @" ";
    NSString     *description = @" ";
    
    if( data != nil ){
        rsid = data.rsid;
        mim = data.mim;
        description = data.omimDescription;
    }
    
    self.infoFields = [data uniqueFields] ;
   
    self.totalDifferenceInLoads++;
    [self.snpWebview stopLoading:nil];
    [self.omimWebview stopLoading:nil];
    
    NSURL *u = [NSURL URLWithString:[data getSNPUrl]];
    self.currentSNPURL = u;
    [[self.snpWebview mainFrame] loadRequest: [NSURLRequest requestWithURL:u]];

    NSURL *r = [NSURL URLWithString:[data getMIMUrl]];
    self.currentOMIMURL = r;
    [[self.omimWebview mainFrame] loadRequest: [NSURLRequest requestWithURL:r]];
    self.check.enabled = data.hasMimURL;
    
    self.summaryLabel.stringValue = [NSString stringWithFormat:@"  %@", data.chosenDesription];
    [self.infoTableView reloadData];
}



#pragma mark - webview resource delegate protoccol
-(NSURLRequest*)webView:(WebView *)webView resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource{
    self.progressIndicator.hidden = NO;
    [self.progressIndicator startAnimation:nil];
    
    return request;
}

- (void)webView:(WebView *)sender
       resource:(id)identifier
didFinishLoadingFromDataSource:(WebDataSource *)dataSource{
    
    self.progressIndicator.hidden = YES;
    [self.progressIndicator stopAnimation:nil];

}

-(void)handleSegmentedControlValueChanged:(NSSegmentedControl*)sender{
    if(sender.selectedSegment == 0){
        self.omimWebview.hidden = YES;
        self.snpWebview.hidden = NO;
    }
    else if(sender.selectedSegment == 1){
        self.snpWebview.hidden = YES;
        self.omimWebview.hidden = NO;
    }
}
- (IBAction)currentWebViewBack:(id)sender {
    if(self.webSegmentedControl.selectedSegment == 0){
        [self.snpWebview goBack:sender];
    }
    else if(self.webSegmentedControl.selectedSegment == 1){
        [self.omimWebview goBack:sender];
    }
}
- (IBAction)currentWebViewForward:(id)sender {
    if(self.webSegmentedControl.selectedSegment == 0){
        [self.snpWebview goForward:sender];
    }
    else if(self.webSegmentedControl.selectedSegment == 1){
        [self.omimWebview goForward:sender];
    }
}


@end
