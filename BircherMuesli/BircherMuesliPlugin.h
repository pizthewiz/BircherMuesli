//
//  BircherMuesliPlugin.h
//  BircherMuesli
//
//  Created by Jean-Pierre Mouilleseaux on 26 May 2011.
//  Copyright 2011 Chorded Constructions. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface BircherMuesliPlugIn : QCPlugIn {
@private
    NSMutableArray* _deviceList;
}
@property (nonatomic, assign) NSArray* outputDeviceList;
@end
