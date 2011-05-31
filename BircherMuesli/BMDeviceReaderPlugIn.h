//
//  BMDeviceReaderPlugIn.h
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 27 May 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "AMSerialPort.h"

@interface BMDeviceReaderPlugIn : QCPlugIn <AMSerialPortReadDelegate> {
@private
    AMSerialPort* _serialPort;
    NSString* _devicePath;
    NSUInteger _deviceBaudRate;
    NSString* _data;
    BOOL _dataChanged;
}
@property (nonatomic, assign) NSString* inputDevicePath;
@property (nonatomic) NSUInteger inputDeviceBaudRate;
@property (nonatomic, assign) NSString* outputData;
@end
