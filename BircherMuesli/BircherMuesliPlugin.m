//
//  BircherMuesliPlugIn.m
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 26 May 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import "BircherMuesliPlugIn.h"
#import "BircherMuesli.h"

#define	kQCPlugIn_Name				@"BircherMuesli"
#define	kQCPlugIn_Description		@"BircherMuesli description"

@implementation BircherMuesliPlugIn

+ (NSDictionary*)attributes{
	return [NSDictionary dictionaryWithObjectsAndKeys:
        CCLocalizedString(@"kQCPlugIn_Name", NULL), QCPlugInAttributeNameKey, 
        CCLocalizedString(@"kQCPlugIn_Description", NULL), QCPlugInAttributeDescriptionKey, 
        // TODO - add QCPlugInAttributeCategoriesKey and QCPlugInAttributeExamplesKey
        nil];
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
	return nil;
}

+ (QCPlugInExecutionMode)executionMode{
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode)timeMode {
	return kQCPlugInTimeModeNone;
}

#pragma mark -

- (id)init {
	self = [super init];
	if (self) {
	}	
	return self;
}

- (void)finalize {
	[super finalize];
}

- (void)dealloc {
	[super dealloc];
}


#pragma mark - EXECUTION

- (BOOL)startExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
	
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/
}

- (void)stopExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
}

@end
