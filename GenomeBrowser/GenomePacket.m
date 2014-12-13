//
//  GenomePacket.m
//  GenomeBrowser
//
//  Created by Rodrigo Rallo on 12/9/14.
//  Copyright (c) 2014 Team3. All rights reserved.
//

#import "GenomePacket.h"

@implementation GenomePacket
@synthesize dict;

//URL base formats for the embedded browser.
const NSString* kURLOMIMFormat = @"http://omim.org/entry/%@";
const NSString* kURLOMIMBackup = @"http://omim.org/";
const NSString* kURLSNPBackup = @"http://www.snpedia.com/index.php/SNPedia";


//Constructor method, each JSON entry becomes a GenomePacket object.
//At each step we check field availability to handle holes in the database.
-(id)initWithDictionary:(NSMutableDictionary*)dictionary{
    self.dict = dictionary;
    if (self.dict) {
        self.rsid = self.dict[@"rsid"] != nil               ? self.dict[@"rsid"]        : @"N/A";
        self.chromosome = self.dict[@"chromosome"] != nil   ? self.dict[@"chromosome"]  : @"N/A";
        self.position = self.dict[@"position"] != nil       ? self.dict[@"position"]    : @"N/A";
        self.genotype = self.dict[@"genotype"] != nil       ? self.dict[@"genotype"]    : @"N/A";
        self.phenotype = self.dict[@"phenotype"] != nil     ? self.dict[@"phenotype"]   : @"N/A";
        self.mim = self.dict[@"omim"] != nil                 ? self.dict[@"omim"]         : @"N/A";
        self.omimDescription = self.dict[@"description"] != nil ? self.dict[@"description"] : @"Not Available";
        self.url = self.dict[@"url"] != nil ? self.dict[@"url"] : kURLSNPBackup;
        //Use phenotype if possible, fall back to omim description if needed.
        self.chosenDesription = ![self.phenotype isEqualToString:@"N/A"]? self.phenotype : self.omimDescription;
        self.priority =  (int)[[self.dict allKeys] count];
    }
    return self;
}

//These two fields, description and phenotype get parsed out of the keys, because they are shown in the Summary field to the user.
//If Phenotype is not available, we fall back to the description.
-(NSMutableArray*) uniqueFields{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSString *s in [self.dict allKeys]) {
        //Put separate fields in this conditional
        if (![s isEqualToString:@"description"] && ![s isEqualToString:@"phenotype"]) {
            [arr addObject:s];
        }
    }
    
    //Order the following dictionary fields in this specific order to
    //keep consistency with what we show the user.
    //Other fields will come in arbirtrary order
    NSMutableArray *orderedArray = [[NSMutableArray alloc] initWithCapacity:arr.count];
    int counter = 0;
    if (![self.rsid isEqualToString:@"N/A"]) {
        orderedArray[counter++] = @"rsid";
    }
    if (![self.chromosome isEqualToString:@"N/A"]) {
        orderedArray[counter++] = @"chromosome";
    }
    if (![self.position isEqualToString:@"N/A"]) {
        orderedArray[counter++] = @"position";
    }
    if (![self.genotype isEqualToString:@"N/A"]) {
        orderedArray[counter++] = @"genotype";
    }
    if (![self.mim isEqualToString:@"N/A"]) {
        orderedArray[counter++] = @"omim";
    }
    
    for (NSString *s in arr) {
        if (![orderedArray containsObject:s]){
            [orderedArray addObject:s];
        }
    }
    return orderedArray;
}

//Check if object has OMIM Field
-(BOOL)hasMimURL{
    return (![self.mim isEqualToString:@"N/A"]);
}

//If omim field not available, return homepage link.
- (NSString *)getMIMUrl{
    if ([self hasMimURL]) {
        NSString *format = [kURLOMIMFormat copy];
        NSString *link = [NSString stringWithFormat: format, self.mim];
        return  link;
    }
    return [kURLOMIMBackup copy];
}

//Check if object has SNP number Field
-(BOOL)hasSNPURL{
    return (![self.url isEqualToString:@"N/A"]);
}


//If SNP field not available, return homepage link.
- (NSString *)getSNPUrl{
    if ([self hasSNPURL]) {
        return  self.url;
    }
    else{
        return [kURLSNPBackup copy];
    }
}

@end
