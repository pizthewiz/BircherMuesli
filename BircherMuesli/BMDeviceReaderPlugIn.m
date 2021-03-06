//
//  BMDeviceReaderPlugIn.m
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 27 May 2011.
//  Copyright 2011, 2013 Chorded Constructions. All rights reserved.
//

#import "BMDeviceReaderPlugIn.h"
#import "BircherMuesli.h"
#import "AMSerialPort.h"
#import "AMSerialPortAdditions.h"
#import "AMSerialPortList.h"

@interface BMDeviceReaderPlugIn()
@property (nonatomic, retain) AMSerialPort* serialPort;
@property (nonatomic, retain) NSString* devicePath;
- (void)_didAddSerialPorts:(NSNotification*)notification;
- (void)_didRemoveSerialPorts:(NSNotification*)notification;
- (void)_setupSerialDeviceWithPath:(NSString*)path atBaudRate:(NSUInteger)baudRate;
- (void)_tearDownSerialDevice;
@end

@implementation BMDeviceReaderPlugIn

@dynamic inputDevicePath, inputDeviceBaudRate, outputData;
@synthesize serialPort = _serialPort, devicePath = _devicePath;

+ (NSDictionary*)attributes {
    return @{
        QCPlugInAttributeNameKey: CCLocalizedString(@"DeviceReaderPlugInName", NULL),
        QCPlugInAttributeDescriptionKey: CCLocalizedString(@"DeviceReaderPlugInDescription", NULL),
        QCPlugInAttributeCategoriesKey: @[@"Source"],
        QCPlugInAttributeExamplesKey: @[[[NSBundle bundleForClass:[self class]] URLForResource:BMExampleCompositionName withExtension:@"qtz"], [[NSBundle bundleForClass:[self class]] URLForResource:BMExampleArduinoCompositionName withExtension:@"qtz"]]
    };
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
    [_devicePath release];

	[super finalize];
}

- (void)dealloc {
    [self _tearDownSerialDevice];
    [_devicePath release];

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

    // setup serial port when possible
    if (self.devicePath && _deviceBaudRate)
        [self _setupSerialDeviceWithPath:self.devicePath atBaudRate:_deviceBaudRate];
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
	/*
     Called by Quartz Composer whenever the plug-in instance needs to execute.
     Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
     Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
     */

    if (_dataChanged) {
        self.outputData = _data;
        _dataChanged = NO;
    }

    // bail on empty device path
    if ([self.inputDevicePath isEqualToString:@""]) {
        if (self.serialPort) {
            [self _tearDownSerialDevice];
            self.devicePath = nil;
            _deviceBaudRate = 0;            
        }
        return YES;
    }

    // negotiate serial connection
    if ([self didValueForInputKeyChange:@"inputDevicePath"] || [self didValueForInputKeyChange:@"inputDeviceBaudRate"]) {
        CCDebugLog(@"device path or baud rate changed, will negotiate connection");
        [self _setupSerialDeviceWithPath:self.inputDevicePath atBaudRate:self.inputDeviceBaudRate];

        // store for safe keeping, may be needed in unplug/replug or stop/start
        self.devicePath = self.serialPort ? self.inputDevicePath : nil;
        _deviceBaudRate = self.serialPort ? self.inputDeviceBaudRate : 0;
    }

    // TODO - return NO?
    if (!self.serialPort) {
        return YES;
    }

//    CCDebugLogSelector();

    return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context {
	/*
     Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
     */

//    CCDebugLogSelector();

    [self _tearDownSerialDevice];
}

- (void)stopExecution:(id <QCPlugInContext>)context {
	/*
     Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
     */

//    CCDebugLogSelector();
}

#pragma mark - SERIAL PORT DELEGATE

- (void)serialPort:(AMSerialPort*)serialPort didReadData:(NSData*)data {
//    CCDebugLogSelector();

    if ([data length] > 0) {
        NSString* text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        // NB - assuming newline as separator
        NSString* trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [text release];
        // NB - sometimes receive phantom data only containing newline
        if ([trimmedText length]) {
//            CCDebugLog(@"READ: %@", trimmedText);
            [_data release];
            _data = [trimmedText retain];
            _dataChanged = YES;
        }
        // continue listening
        [serialPort readDataInBackground];
    } else {
        CCErrorLog(@"ERROR - port closed! %@", serialPort.name);
        [self _tearDownSerialDevice];
    }
}

#pragma mark - SERIAL PORT NOTIFICATIONS

- (void)_didAddSerialPorts:(NSNotification*)notification {
//    CCDebugLogSelector();

    AMSerialPort* serialPort = nil;
    NSArray* addedPorts = [[notification userInfo] objectForKey:AMSerialPortListAddedPorts];
    for (AMSerialPort* p in addedPorts) {
        if (![[p bsdPath] isEqualToString:self.devicePath])
            continue;
        serialPort = p;
        break;
    }

    if (!serialPort)
        return;

    [self _setupSerialDeviceWithPath:self.devicePath atBaudRate:_deviceBaudRate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AMSerialPortListDidAddPortsNotification object:nil];
}


- (void)_didRemoveSerialPorts:(NSNotification*)notification {
//    CCDebugLogSelector();

    NSArray* removedPorts = [[notification userInfo] objectForKey:AMSerialPortListRemovedPorts];
    if (![removedPorts containsObject:self.serialPort])
        return;

    CCWarningLog(@"WARNING - serial device '%@' was yanked", self.serialPort.bsdPath);

    [self _tearDownSerialDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didAddSerialPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
}

#pragma mark - PRIVATE

- (void)_setupSerialDeviceWithPath:(NSString*)path atBaudRate:(NSUInteger)baudRate {
//    CCDebugLogSelector();

    [self _tearDownSerialDevice];

    AMSerialPort* serialPort = [[AMSerialPortList sharedPortList] serialPortForPath:path];
    if (!serialPort) {
        CCErrorLog(@"ERROR - failed to find serial port at path '%@' to attach to", path);
        return;
    }

    if (![serialPort available]) {
        CCErrorLog(@"ERROR - serial port '%@' is not available", serialPort.bsdPath);
        return;
    }

    if (serialPort.readDelegate) {
        CCErrorLog(@"ERROR - serial port '%@' already has read delegate", serialPort.bsdPath);
        return;
    }
    serialPort.readDelegate = self;

    id fileHandle = [serialPort open];
    if (!fileHandle) {
        // TODO - would be nice if we could fetch the error
        CCErrorLog(@"ERROR - failed to open serial port %@ - %s(%d)", serialPort.bsdPath, strerror(errno), errno);
        serialPort.readDelegate = nil;
        return;
    }

    // set port speed
    int status = [serialPort setSpeed:baudRate];
    if (status != 0) {
        CCErrorLog(@"ERROR - failed to set speed %lu with error %s(%d) on port: %@", (unsigned long)baudRate, strerror(status), status, serialPort.bsdPath);
        serialPort.readDelegate = nil;
        return;
    }
    status = [serialPort commitChanges];
    if (status != 0) {
        CCErrorLog(@"ERROR - failed to commit changes with error %s(%d) after setting speed %lu on port: %@", strerror(status), status, (unsigned long)baudRate, serialPort.bsdPath);
        serialPort.readDelegate = nil;
        return;
    }

    self.serialPort = serialPort;
    [self.serialPort readDataInBackground];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didRemoveSerialPorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];
}

- (void)_tearDownSerialDevice {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AMSerialPortListDidRemovePortsNotification object:nil];

    [self.serialPort stopReadInBackground];
    self.serialPort.readDelegate = nil;
    [self.serialPort free];
    self.serialPort = nil;

    [_data release];
    _data = nil;
    _dataChanged = YES;
}

@end
