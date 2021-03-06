//
//  Constants.h
//  AdmitOne
//
//  Created by Anthony Plourde on 12-01-09.
//  Copyright (c) 2012 Anthony Plourde.
//      
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#ifndef AdmitOne_Constants_h
#define AdmitOne_Constants_h


//NSUserDefaults Keys

#define kAPDownloadFileName @"kAPDownloadFileName"

#define kAPDownloadFolder @"kAPDownloadFolder"
#define kAPDownloadFolderDefault @"~/Downloads"

#define kAPUseSystemAppToDownload @"kAPUseSystemAppToDownload"
#define kAPUseSystemAppToDownloadDefault NO

//AdmitOne API
#define kAdmitOneApiEndPoint @"http://admitoneapp.com/admitone/api"
#define kAdmitOneApiResourceTrailer @"/movies/trailer?title=%@&imdbId=%@"
#define kAdmitOneApiResourceTopRentals @"/movies/topRentals"
#define kAdmitOneApiResourceNewReleases @"/movies/newReleases"
#define kAdmitOneApiResourceCurrentReleases @"/movies/currentReleases"
#define kAdmitOneApiResourceSearch @"/movies/search?keywords=%@"
#define kAdmitOneApiResourceTorrent @"/torrents/movie?title=%@&year=%@&language=%@&quality=%@"

#endif
