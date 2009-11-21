//
//  LanguageDefn.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Language.h"
#import "OxNSArray.h"
#import "GreekLanguage.h"
#import "FrenchLanguage.h"
#import "Ox.h"
#import "OxNSString.h"
#import "OxNSObject.h"

static NSArray *allLanguagesArray;
static dispatch_once_t allLanguagesPred;

NSArray *allLanguages() 
{
	dispatch_once(&allLanguagesPred, ^{
		allLanguagesArray = [OxArr([GreekLanguage new], [FrenchLanguage new]) retain];
	});
	return allLanguagesArray;
}
