//
//  BMDeviceListPlugIn.m
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 26 May 2011.
//  Copyright 2011, 2013 Chorded Constructions. All rights reserved.
//

#import "BMDeviceListPlugIn.h"
#import "BircherMuesli.h"
#import "AMSerialPortList.h"
#import "AMSerialPort.h"

@interface BMDeviceListPlugIn()
- (void)_didAddSerialPorts:(NSNotification*)notification;
- (void)_didRemoveSerialPorts:(NSNotification*)notification;
- (void)_setupPortListening;
- (void)_tearDownPortListening;
@end

@implementation BMDeviceListPlugIn

@dynamic outputDeviceList, outputDeviceListUpdatedSignal;

+ (NSDictionary*)attributes {
    return @{
        QCPlugInAttributeNameKey: CCLocalizedString(@"DeviceListPlugInName", NULL),
        QCPlugInAttributeDescriptionKey: CCLocalizedString(@"DeviceListPlugInDescription", NULL),
        QCPlugInAttributeCategoriesKey: @[@"Source"],
        QCPlugInAttributeExamplesKey: @[[[NSBundle bundleForClass:[self class]] URLForResource:BMExampleCompositionName withExtension:@"qtz"],
        [[NSBundle bundleForClass:[self class]] URLForResource:BMExampleArduinoCompositionName withExtension:@"qtz"]]
    };
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
    if ([key isEqualToString:@"outputDeviceList"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Device List", QCPortAttributeNameKey, nil];
    else if ([key isEqualToString:@"outputDeviceListUpdatedSignal"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"List Updated", QCPortAttributeNameKey, nil];
	return nil;
}

+ (QCPlugInExecutionMode)executionMode{
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode {
	return kQCPlugInTimeModeIdle;
}

#pragma mark -

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

//    CCDebugLogSelector();

	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/

//    CCDebugLogSelector();

    [self _setupPortListening];
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	*/

    if (!_deviceListUpdatedSignalDidChange)
        return YES;

    if (_deviceListUpdatedSignal)
        self.outputDeviceList = _deviceList;
    self.outputDeviceListUpdatedSignal = _deviceListUpdatedSignal;
    _deviceListUpdatedSignalDidChange = _deviceListUpdatedSignal;
    _deviceListUpdatedSignal = NO;

	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/

//    CCDebugLogSelector();

    [self _tearDownPortListening];
}

- (void)stopExecution:(id <QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/

//    CCDebugLogSelector();
}

#pragma mark - SERIAL PORT NOTIFICATIONS

- (void)_didAddSerialPorts:(NSNotification*)notification {
//    CCDebugLogSelector();

    NSArray* addedPorts = [[notification userInfo] objectForKey:AMSerialPortListAddedPorts];
    for (AMSerialPort* serialPort in addedPorts) {
        CCDebugLog(@"ADDING PORT: %@", serialPort);
        [_deviceList addObject:serialPort.bsdPath];
    }

    _deviceListUpdatedSignal = YES;
    _deviceListUpdatedSignalDidChange = YES;
}

- (void)_didRemoveSerialPorts:(NSNotification*)notification {
//    CCDebugLogSelector();

    NSArray* removedPorts = [[notification userInfo] objectForKey:AMSerialPortListRemovedPorts];
    for (AMSerialPort* serialPort in removedPorts) {
        CCDebugLog(@"REMOVING PORT: %@", serialPort);
        if ([_deviceList indexOfObject:serialPort.bsdPath] == NSNotFound)
            CCErrorLog(@"WARNING - attempting to remove port at path '%@' not in device list %@", serialPort.bsdPath, _deviceList);
        [_deviceList removeObject:[serialPort bsdPath]];
    }

    _deviceListUpdatedSignal = YES;
    _deviceListUpdatedSignalDidChange = YES;
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

    _deviceListUpdatedSignal = YES;
    _deviceListUpdatedSignalDidChange = YES;
}

- (void)_tearDownPortListening {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AMSerialPortListDidAddPortsNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AMSerialPortListDidRemovePortsNotification object:nil];

    [_deviceList release];
    _deviceList = nil;

    _deviceListUpdatedSignal = YES;
    _deviceListUpdatedSignalDidChange = YES;
}

@end
