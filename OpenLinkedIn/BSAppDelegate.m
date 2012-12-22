//
//  BSAppDelegate.m
//  OpenLinkedIn
//
//  Created by Sasmito Adibowo on 22-12-12.
//  Copyright (c) 2012 Basil Salad Software. All rights reserved.
//  http://basilsalad.com
//
//  Licensed under the BSD License <http://www.opensource.org/licenses/bsd-license>
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
//  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
//  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BSAppDelegate.h"

NSString* const BSAppDelegateQuitNofification = @"com.basilsalad.BSAppDelegateQuitNofification";

@implementation BSAppDelegate

-(void) handleQuitNotification:(NSNotification*) notification
{
    [[NSApplication sharedApplication] terminate:self];
}


+(NSRegularExpression*) profileStringRegularExpression
{
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\#profile\\/([0-9]+)" options:0 error:nil];
        
    });
    return regex;
}


- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent: (NSAppleEventDescriptor *)replyEvent
{
    NSString* urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    
    NSRegularExpression* regex = [[self class] profileStringRegularExpression];
    [regex enumerateMatchesInString:urlString options:0 range:NSMakeRange(0, urlString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSUInteger numberOfRanges = result.numberOfRanges;
        if (numberOfRanges == 2) {
            NSRange range = [result rangeAtIndex:1];
            NSString* profileIDString = [urlString substringWithRange:range];
            
            NSString* profileURLString = [NSString stringWithFormat:@"http://www.linkedin.com/profile/view?id=%@",profileIDString];
            if([[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:profileURLString]]) {
                NSNotification* quitNotification = [NSNotification notificationWithName:BSAppDelegateQuitNofification object:self];
                [[NSNotificationQueue defaultQueue] enqueueNotification:quitNotification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes:nil];
            }
        }
    }];
}


#pragma mark NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager* appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuitNotification:) name:BSAppDelegateQuitNofification object:self];
}



@end
