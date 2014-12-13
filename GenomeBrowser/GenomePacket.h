//
//  GenomePacket.h
//  GenomeBrowser
//
//  Created by Rodrigo Rallo on 12/9/14.
//  Copyright (c) 2014 Team3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenomePacket : NSObject

@property (strong, nonatomic) NSMutableDictionary* dict;


@property(strong, nonatomic) NSString* rsid;
@property(strong, nonatomic) NSString* chromosome;
@property(strong, nonatomic) NSString* position;
@property(strong, nonatomic) NSString* genotype;
@property(strong, nonatomic) NSString* phenotype;
@property(strong, nonatomic) NSString* mim;
@property(strong, nonatomic) NSString* omimDescription;
@property(strong, nonatomic) NSString* chosenDesription;
@property(strong, nonatomic) NSString* url;
@property(nonatomic) int priority;

-(id) initWithDictionary:(NSMutableDictionary*)dictionary;
-(NSMutableArray*) uniqueFields;


-(BOOL)hasMimURL;
- (NSString *)getMIMUrl;
-(BOOL)hasSNPURL;
- (NSString *)getSNPUrl;
@end
