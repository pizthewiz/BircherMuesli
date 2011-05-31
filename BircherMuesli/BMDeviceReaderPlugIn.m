//
//  BMDeviceReaderPlugIn.m
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 27 May 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import "BMDeviceReaderPlugIn.h"
#import "BircherMuesli.h"
#import "AMSerialPort.h"
#import "AMSerialPortAdditions.h"
#import "AMSerialPortList.h"

@interface BMDeviceReaderPlugIn()
@property (nonatomic, retain) AMSerialPort* serialPort;
- (void)_setupSerialDeviceWithPath:(NSString*)path atBaudRate:(NSUInteger)baudRate;
- (void)_tearDownSerialDevice;
@end

@implementation BMDeviceReaderPlugIn

@dynamic inputDevicePath, inputDeviceBaudRate, outputData;
@synthesize serialPort = _serialPort;

+ (NSDictionary*)attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
        CCLocalizedString(@"DeviceReaderPlugInName", NULL), QCPlugInAttributeNameKey, 
        CCLocalizedString(@"DeviceReaderPlugInDescription", NULL), QCPlugInAttributeDescriptionKey, 
        // TODO - add QCPlugInAttributeCategoriesKey and QCPlugInAttributeExamplesKey
        nil];
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
    if ([key isEqualToString:@"inputDevicePath"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Device", QCPortAttributeNameKey, nil];
    else if ([key isEqualToString:@"inputDeviceBaudRate"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Baud Rate", QCPortAttributeNameKey, 
                    [NSNumber numberWithUnsignedInteger:0], QCPortAttributeMinimumValueKey,
                    [NSNumber numberWithUnsignedInteger:115200], QCPortAttributeMaximumValueKey, 
                    [NSNumber numberWithUnsignedInteger:9600], QCPortAttributeDefaultValueKey, nil];
    else if ([key isEqualToString:@"outputData"])
        return [NSDictionary dictionaryWithObjectsAndKeys:@"Data", QCPortAttributeNameKey, nil];
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
    [self _tearDownSerialDevice];

	[super finalize];
}

- (void)dealloc {
    [self _tearDownSerialDevice];

	[super dealloc];
}

#pragma mark - EXECUTION

- (BOOL)startExecution:(id <QCPlugInContext>)context {
	/*
     Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
     Return NO in case of fatal failure (this will prevent rendering of the composition to start).
     */

    CCDebugLogSelector();

	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context {
	/*
     Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
     */

    CCDebugLogSelector();
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
	/*
     Called by Quartz Composer whenever the plug-in instance needs to execute.
     Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
     Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
     */

//    if (dataChanged) {
//        self.outputData = _outputData;
//    }

    // bail on empty device path
    if ([self.inputDevicePath isEqualToString:@""])
        return YES;

    // negotiate serial connection
    if ([self didValueForInputKeyChange:@"inputDevicePath"] || [self didValueForInputKeyChange:@"inputDeviceBaudRate"]) {
        [self _setupSerialDeviceWithPath:self.inputDevicePath atBaudRate:self.inputDeviceBaudRate];
    }

    // TODO - return NO?
    if (!_serialPort) {
        return YES;
    }

//    CCDebugLogSelector();

    return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
	/*
     Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
     */

    CCDebugLogSelector();
}

- (void)stopExecution:(id <QCPlugInContext>)context {
	/*
     Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
     */

    CCDebugLogSelector();

    // TODO - should tear down serial device
    [self _tearDownSerialDevice];
}

#pragma mark - SERIAL PORT DELEGATE

- (void)serialPort:(AMSerialPort*) readData:(NSData*)data {
    CCDebugLogSelector();
}

#pragma mark - PRIVATE

- (void)_setupSerialDeviceWithPath:(NSString*)path atBaudRate:(NSUInteger)baudRate {
    CCDebugLogSelector();

    [self _tearDownSerialDevice];

    AMSerialPort* serialPort = [[AMSerialPortList sharedPortList] serialPortWithPath:path];
    if (!serialPort) {
        CCErrorLog(@"ERROR - failed to find serial port at path '%@' to attach to", path);
        return;
    }

    if (![serialPort available]) {
        CCErrorLog(@"ERROR - serial port '%@' is not available", serialPort);
        return;
    }

    [serialPort setDelegate:self];

    id fileHandle = [serialPort open];
    if (!fileHandle) {
        CCErrorLog(@"ERROR - failed to open serial port: %@", serialPort);
        return;
    }

    // NB - strangely set spead after opening
    [serialPort setSpeed:baudRate];
    BOOL status = [serialPort commitChanges];
    if (!status) {
        CCErrorLog(@"ERROR - failed to set speed %lu on port: %@", baudRate, serialPort);
    }

    self.serialPort = serialPort;
    [self.serialPort readDataInBackground];
}

- (void)_tearDownSerialDevice {
//    [self.serialPort setDelegate:nil];
    [self.serialPort stopReadInBackground];
    [self.serialPort free];
    self.serialPort = nil;
}

@end
