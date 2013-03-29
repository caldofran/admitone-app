//
//  APTorrentList.m
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-10.
//  Copyright (c) 2012 Anthony Plourde. All rights reserved.
//

#import "APTorrentList.h"
#import "Torrent.h"
#import "bencode.h"
#import "FileListNode.h"
#import "Constants.h"

@implementation APTorrentList

@synthesize list = _list;

static APTorrentList *sharedInstance = nil;
+ (APTorrentList*) sharedInstance{
    @synchronized([APTorrentList class]){
        if (!sharedInstance) {
            sharedInstance = [[self alloc]init];
        }
        return sharedInstance;
    }
    return nil;
}

- (id)init{
    if ((self = [super init])) {
        self.list = [[NSMutableArray alloc]init];
        
        
        
        NSUserDefaults *fDefaults = [[NSUserDefaults alloc]init];
        [fDefaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle]resourcePath]stringByAppendingFormat:@"/%@",@"Defaults.plist"]]];

        //checks for old version speeds of -1
        if ([fDefaults integerForKey: @"UploadLimit"] < 0)
        {
            [fDefaults removeObjectForKey: @"UploadLimit"];
            [fDefaults setBool: NO forKey: @"CheckUpload"];
        }
        if ([fDefaults integerForKey: @"DownloadLimit"] < 0)
        {
            [fDefaults removeObjectForKey: @"DownloadLimit"];
            [fDefaults setBool: NO forKey: @"CheckDownload"];
        }
        
        //upgrading from versions < 2.40: clear recent items
        [[NSDocumentController sharedDocumentController] clearRecentDocuments: nil];
        
        tr_benc settings;
        tr_bencInitDict(&settings, 41);
        tr_sessionGetDefaultSettings(&settings);
        
        const BOOL usesSpeedLimitSched = [fDefaults boolForKey: @"SpeedLimitAuto"];
        if (!usesSpeedLimitSched)
            tr_bencDictAddBool(&settings, TR_PREFS_KEY_ALT_SPEED_ENABLED, [fDefaults boolForKey: @"SpeedLimit"]);
        
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_UP_KBps, [fDefaults integerForKey: @"SpeedLimitUploadLimit"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_DOWN_KBps, [fDefaults integerForKey: @"SpeedLimitDownloadLimit"]);
        
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_ENABLED, [fDefaults boolForKey: @"SpeedLimitAuto"]);
//        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_BEGIN, [[fDefaults objectForKey: @"SpeedLimitAutoOnDate"] intValue]);
//        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_END, [[fDefaults objectForKey: @"SpeedLimitAutoOffDate"] intValue]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_DAY, [fDefaults integerForKey: @"SpeedLimitAutoDay"]);
        
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_DSPEED_KBps, [fDefaults integerForKey: @"DownloadLimit"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_DSPEED_ENABLED, [fDefaults boolForKey: @"CheckDownload"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_USPEED_KBps, [fDefaults integerForKey: @"UploadLimit"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_USPEED_ENABLED, [fDefaults boolForKey: @"CheckUpload"]);
        
        //hidden prefs
        if ([fDefaults objectForKey: @"BindAddressIPv4"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_BIND_ADDRESS_IPV4, [[fDefaults stringForKey: @"BindAddressIPv4"] UTF8String]);
        if ([fDefaults objectForKey: @"BindAddressIPv6"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_BIND_ADDRESS_IPV6, [[fDefaults stringForKey: @"BindAddressIPv6"] UTF8String]);
        
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_BLOCKLIST_ENABLED, [fDefaults boolForKey: @"BlocklistNew"]);
        if ([fDefaults objectForKey: @"BlocklistURL"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_BLOCKLIST_URL, [[fDefaults stringForKey: @"BlocklistURL"] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_DHT_ENABLED, [fDefaults boolForKey: @"DHTGlobal"]);
        tr_bencDictAddStr(&settings, TR_PREFS_KEY_DOWNLOAD_DIR, [[[fDefaults stringForKey: @"DownloadFolder"]
                                                                  stringByExpandingTildeInPath] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_DOWNLOAD_QUEUE_ENABLED, [fDefaults boolForKey: @"Queue"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_DOWNLOAD_QUEUE_SIZE, [fDefaults integerForKey: @"QueueDownloadNumber"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_IDLE_LIMIT, [fDefaults integerForKey: @"IdleLimitMinutes"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_IDLE_LIMIT_ENABLED, [fDefaults boolForKey: @"IdleLimitCheck"]);
        tr_bencDictAddStr(&settings, TR_PREFS_KEY_INCOMPLETE_DIR, [[[fDefaults stringForKey: @"IncompleteDownloadFolder"]
                                                                    stringByExpandingTildeInPath] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_INCOMPLETE_DIR_ENABLED, [fDefaults boolForKey: @"UseIncompleteDownloadFolder"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_LPD_ENABLED, [fDefaults boolForKey: @"LocalPeerDiscoveryGlobal"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_MSGLEVEL, TR_MSG_DBG);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_LIMIT_GLOBAL, [fDefaults integerForKey: @"PeersTotal"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_LIMIT_TORRENT, [fDefaults integerForKey: @"PeersTorrent"]);
        
        const BOOL randomPort = [fDefaults boolForKey: @"RandomPort"];
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_PEER_PORT_RANDOM_ON_START, randomPort);
        if (!randomPort)
            tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_PORT, [fDefaults integerForKey: @"BindPort"]);
        
        //hidden pref
        if ([fDefaults objectForKey: @"PeerSocketTOS"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_PEER_SOCKET_TOS, [[fDefaults stringForKey: @"PeerSocketTOS"] UTF8String]);
        
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_PEX_ENABLED, [fDefaults boolForKey: @"PEXGlobal"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_PORT_FORWARDING, [fDefaults boolForKey: @"NatTraversal"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_QUEUE_STALLED_ENABLED, [fDefaults boolForKey: @"CheckStalled"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_QUEUE_STALLED_MINUTES, [fDefaults integerForKey: @"StalledMinutes"]);
        tr_bencDictAddReal(&settings, TR_PREFS_KEY_RATIO, [[fDefaults objectForKey:@"RatioLimit"] floatValue]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RATIO_ENABLED, [fDefaults boolForKey: @"RatioCheck"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RENAME_PARTIAL_FILES, [fDefaults boolForKey: @"RenamePartialFiles"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_AUTH_REQUIRED,  [fDefaults boolForKey: @"RPCAuthorize"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_ENABLED,  [fDefaults boolForKey: @"RPC"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_RPC_PORT, [fDefaults integerForKey: @"RPCPort"]);
        tr_bencDictAddStr(&settings, TR_PREFS_KEY_RPC_USERNAME,  [[fDefaults stringForKey: @"RPCUsername"] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_WHITELIST_ENABLED,  [fDefaults boolForKey: @"RPCUseWhitelist"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_SEED_QUEUE_ENABLED, [fDefaults boolForKey: @"QueueSeed"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_SEED_QUEUE_SIZE, [fDefaults integerForKey: @"QueueSeedNumber"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_START, [fDefaults boolForKey: @"AutoStartDownload"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_SCRIPT_TORRENT_DONE_ENABLED, [fDefaults boolForKey: @"DoneScriptEnabled"]);
        tr_bencDictAddStr(&settings, TR_PREFS_KEY_SCRIPT_TORRENT_DONE_FILENAME, [[fDefaults stringForKey: @"DoneScriptPath"] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_UTP_ENABLED, [fDefaults boolForKey: @"UTPGlobal"]);
        
        tr_formatter_size_init(1000,
                               [NSLocalizedString(@"KB", "File size - kilobytes") UTF8String],
                               [NSLocalizedString(@"MB", "File size - megabytes") UTF8String],
                               [NSLocalizedString(@"GB", "File size - gigabytes") UTF8String],
                               [NSLocalizedString(@"TB", "File size - terabytes") UTF8String]);
        
        tr_formatter_speed_init(1000,
                                [NSLocalizedString(@"KB/s", "Transfer speed (kilobytes per second)") UTF8String],
                                [NSLocalizedString(@"MB/s", "Transfer speed (megabytes per second)") UTF8String],
                                [NSLocalizedString(@"GB/s", "Transfer speed (gigabytes per second)") UTF8String],
                                [NSLocalizedString(@"TB/s", "Transfer speed (terabytes per second)") UTF8String]); //why not?
        
        tr_formatter_mem_init(1024, [NSLocalizedString(@"KB", "Memory size - kilobytes") UTF8String],
                              [NSLocalizedString(@"MB", "Memory size - megabytes") UTF8String],
                              [NSLocalizedString(@"GB", "Memory size - gigabytes") UTF8String],
                              [NSLocalizedString(@"TB", "Memory size - terabytes") UTF8String]);
        
        const char * configDir = tr_getDefaultConfigDir("AdmitOne");
        fLib = tr_sessionInit("macosx", configDir, YES, &settings);
        tr_bencFree(&settings);
        
    }
    return self;
}

- (void)addTorrentsAtPaths:(NSArray*)paths{
    
    NSString *downloadDir = [[NSUserDefaults standardUserDefaults]objectForKey:kAPDownloadFolder];
    for (NSString *path in paths) {
        if ([path hasSuffix:@".torrent"]) {
            NSArray *applicationSupportDirectories = NSSearchPathForDirectoriesInDomains (NSApplicationSupportDirectory, NSUserDomainMask, YES);
            path =  [[applicationSupportDirectories objectAtIndex:0] stringByAppendingFormat:@"/AdmitOne/Temp/%@",path];
            Torrent *t = [[Torrent alloc]initWithPath:path location:downloadDir deleteTorrentFile:NO lib:fLib];
            if (t) {
                //trying to only check video files
//                for (int i=0;i<[[t flatFileList]count];i++) {
//                    FileListNode * fileListNode = [[t flatFileList]objectAtIndex:i];
//                    NSString *file = [fileListNode name];
//                    CFStringRef fileExtension = (CFStringRef) [file pathExtension];
//                    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
//                    if (UTTypeConformsTo(fileUTI, kUTTypeMovie)){
//                        [t setFileCheckState:1 forIndexes:[fileListNode indexes]];
//                        NSLog(@"%@ is a movie file",file);
//                    }
//                    else{
//                        [t setFileCheckState:0 forIndexes:[fileListNode indexes]];
//                        NSLog(@"%@ is not a movie",file);
//                    }
//                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"IsActive - %@",[t name]]] ||
                    ![[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"IsActive - %@",[t name]]]) {
                    [t startTransfer];
                }
                [t setQueuePosition: [_list count]];
                [t update];
                [self.list addObject:t];
                [t release];
//                NSLog(@"Torrent : %@",[t name]);
            }
        }
    }
}

- (void)addTorrentAtPath:(NSString*)path{
    
}

- (void)removeTorrentAtPath:(NSString*)path{
    
}

@end
