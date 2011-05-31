//
//  BMDeviceWriterPlugIn.h
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 31 May 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "AMSerialPort.h"

@interface BMDeviceWriterPlugIn : QCPlugIn <AMSerialPortDelegate> {
@private
    AMSerialPort* _serialPort;
    NSString* _devicePath;
    NSUInteger _deviceBaudRate;
}
@property (nonatomic, assign) NSString* inputDevicePath;
@property (nonatomic) NSUInteger inputDeviceBaudRate;
@property (nonatomic, assign) NSString* inputData;
@property (nonatomic) BOOL inputSendSignal;
@end
