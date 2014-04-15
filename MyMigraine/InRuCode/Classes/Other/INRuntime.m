//!
//! @file INRuntime.m
//!
//! @author Murad Kakabayev (murad.kakabayev@gmail.com)
//! @version 1.0
//! @date 2011
//! 
//! Copyright © 2010-2011 InRu
//! 
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//! 
//!     http://www.apache.org/licenses/LICENSE-2.0
//! 
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.
//!
//++/

#import "INRuntime.h"
#import <objc/runtime.h>

//----------------------------------------------------------------------------------------------------------------------------------

/*
    Код взят отсюда. Там объясняется, для чего это надо и как использовать
  
    http://www.cocoadev.com/index.pl?MethodSwizzling
 
    In researching this, it seems to me that the existing solutions for the Leopard runtime are extremely over-engineered. \
    There are two cases to consider: the subclass implements the method you're replacing, or it inherits it. In the former case, 
    method_exchangeImplementations gets the job done. In the latter case, class_addMethod on the "old" selector with the new method, 
    followed by class_replaceMethod on the "new" selector with the old method, will get things into a good place. Since class_addMethod 
    returns success or failure based on whether the class in question already has such a method, this results in this easy code: 
  
    Типичный метод - патчим класс для вывода в лог функции
   
    @interface NSObject (AA)

    @end

    @implementation NSObject (AA)

    - (void)newDealloc {
        NSLog(@"%@ is being deallocated", self);
        [self newDealloc];
    }

    @end
  
    ...
    
    INSwizzleSelectors(UIView.class, @selector(dealloc), @selector(newDealloc)); // будет работать для UIView и наследников
    
    Внимание! Операция одноразовая! Подробно возможность вернуть все назад я не исследовал, за отсутствием необходимости.
*/

void INSwizzleSelectors(Class c, SEL originalSelector, SEL newSelector) {
    Method origMethod = class_getInstanceMethod(c, originalSelector);
    NSCAssert(origMethod,@"%@ does not implement method %@", NSStringFromSelector(originalSelector));

    Method newMethod = class_getInstanceMethod(c, newSelector);
    NSCAssert(newMethod,@"%@ does not implement method %@", NSStringFromSelector(newSelector));

    if (class_addMethod(c, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) { 
        class_replaceMethod(c, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

//----------------------------------------------------------------------------------------------------------------------------------
