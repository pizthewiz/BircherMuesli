//
//  BMDeviceListPlugIn.h
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 26 May 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface BMDeviceListPlugIn : QCPlugIn {
@private
    NSMutableArray* _deviceList;
    BOOL _deviceListChanged;
}
@property (nonatomic, assign) NSArray* outputDeviceList;
@property (nonatomic) BOOL outputListUpdated;
@end
