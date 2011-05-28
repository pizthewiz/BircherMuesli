//
//  BircherMuesliPlugIn.m
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 26 May 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import "BircherMuesliPlugIn.h"
#import "BircherMuesli.h"
#import "AMSerialPortList.h"
#import "AMSerialPort.h"

@interface BircherMuesliPlugIn()
- (void)_setupPortListening;
- (void)_tearDownPortListening;
- (void)_didAddSerialPorts:(NSNotification*)notification;
- (void)_didRemoveSerialPorts:(NSNotification*)notification;
@end

@implementation BircherMuesliPlugIn

@dynamic outputDeviceList;

+ (NSDictionary*)attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
        CCLocalizedString(@"kQCPlugIn_Name", NULL), QCPlugInAttributeNameKey, 
        CCLocalizedString(@"kQCPlugIn_Description", NULL), QCPlugInAttributeDescriptionKey, 
        // TODO - add QCPlugInAttributeCategoriesKey and QCPlugInAttributeExamplesKey
        nil];
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
    if ([key isEqualToString:@"outputDeviceList"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Device List", QCPortAttributeNameKey, nil];
	return nil;
}

+ (QCPlugInExecutionMode)executionMode{
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode {
	return kQCPlugInTimeModeIdle;
}

#pragma mark -

- (id)init {
	self = [super init];
	if (self) {
	}
	return self;
}

- (void)finalize {
    [self _tearDownPortListening];

	[super finalize];
}

- (void)dealloc {
    [self _tearDownPortListening];

	[super dealloc];
}

#pragma mark - EXECUTION

- (BOOL)startExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/

    // NB - might not be necessary to tear it down entirely
    [self _setupPortListening];

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
	*/

    if (!_deviceListChanged)
        return YES;

    self.outputDeviceList = _deviceList;
    _deviceListChanged = NO;

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

#pragma mark - PRIVATE

- (void)_setupPortListening {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAddSerialPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didRemoveSerialPorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];

    _deviceList = [[NSMutableArray alloc] init];

    // list ports
    NSArray* serialPorts = [[AMSerialPortList sharedPortList] serialPorts];
    for (AMSerialPort* serialPort in serialPorts) {
        CCDebugLog(@"PORT: %@", serialPort);
        [_deviceList addObject:[serialPort bsdPath]];
    }

    _deviceListChanged = [_deviceList count] != 0;
}

- (void)_tearDownPortListening {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AMSerialPortListDidRemovePortsNotification object:nil];

    [_deviceList release];
    _deviceList = nil;
}

- (void)_didAddSerialPorts:(NSNotification*)notification {
    CCDebugLogSelector();

    NSArray* addedPorts = [[notification userInfo] objectForKey:AMSerialPortListAddedPorts];
    for (AMSerialPort* serialPort in addedPorts) {
        CCDebugLog(@"ADDING PORT: %@", serialPort);
        [_deviceList addObject:[serialPort bsdPath]];
    }

    _deviceListChanged = YES;
}

- (void)_didRemoveSerialPorts:(NSNotification*)notification {
    CCDebugLogSelector();

    NSArray* removedPorts = [[notification userInfo] objectForKey:AMSerialPortListRemovedPorts];
    for (AMSerialPort* serialPort in removedPorts) {
        CCDebugLog(@"REMOVING PORT: %@", serialPort);
        if (![_deviceList indexOfObject:[serialPort bsdPath]])
            NSLog(@"WARNING - attempting to remove port not in device list");
        [_deviceList removeObject:[serialPort bsdPath]];
    }

    _deviceListChanged = YES;
}

@end
