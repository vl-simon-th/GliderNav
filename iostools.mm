#include "iostools.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include <qdebug.h>

void IosTools::setLockScreenTimerDisabled()
{
  [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
  qDebug() << "Lock Screen Timer disabled";
}
