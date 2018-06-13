//
//  Monster.swift
//  Shooter
//
//  Created by kotta on 12/06/2018.
//  Copyright © 2018 Starblo Hong. All rights reserved.
//

import Foundation
import CoreFoundation
import os
import UIKit
import ARKit

struct PropertyKey {
    static var initPosition = "initPosition"
    static var animationPostion = "initPosition"
    static var currentPosition = "currentPosition"
    static var id = "id"
    static var dead = "dead"
}

class Monster: NSObject, NSCoding {
    var initPostion: SCNVector3;
    var animationPostion: SCNVector3;
    var currentPostion: SCNVector3;
    var dead = false;
    var id = genId();
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(initPostion, forKey: PropertyKey.initPosition);
        aCoder.encode(animationPostion, forKey: PropertyKey.initPosition);
        aCoder.encode(currentPostion, forKey: PropertyKey.currentPosition);
        aCoder.encode(id, forKey: PropertyKey.id);
        aCoder.encode(dead, forKey: PropertyKey.dead);
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let ip = aDecoder.decodeObject(forKey: PropertyKey.initPosition) as? SCNVector3 else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let ap = aDecoder.decodeObject(forKey: PropertyKey.animationPostion) as? SCNVector3 else {
            return nil;
        }
        
        guard  let cp = aDecoder.decodeObject(forKey: PropertyKey.currentPosition) as? SCNVector3 else {
            return nil;
        }
        
        guard let i = aDecoder.decodeObject(forKey: PropertyKey.id) as? String else {
            return nil;
        }
        
        let dd = aDecoder.decodeBool(forKey: PropertyKey.dead);
        
        self.init(ip, ap, cp, i, dd);
    }
    
    init(_ ip: SCNVector3, _ ap: SCNVector3, _ cp: SCNVector3, _ i : String, _ dd: Bool) {
        initPostion = SCNVector3Make(ip.x, ip.y, ip.z)
        animationPostion = SCNVector3Make(ap.x, ap.y, ap.z);
        currentPostion = SCNVector3Make(cp.x, cp.y, cp.z);
        id = i;
        dead = dd;
    }
    
    override init() {
        initPostion = SCNVector3Make(random(), random(), random())
        animationPostion = SCNVector3Make(random(), random(), random())
        currentPostion = SCNVector3Make(initPostion.x, initPostion.y, initPostion.z);
        id = genId();
        dead = false;
    }
}

struct GameInfoProperty {
    static var timeRemain = "timeRemain"
    static var initMonsterCount = "initMonsterSount"
    static var hitCount = "hitCount"
    static var monsters = "monsters"
    static var bgMusicOn = "bgMusicOn"
    static var soundEffectOn = "soundEffectOn"
    static var timeLimiting = "timeLimiting"
    static var animating = "animating"
    static var infinityMode = "infinityMode"
}

class GameInfo : NSObject, NSCoding {
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("gameinfo")
    
    var timeRemain = 60;
    var initMonsterCount = 10;
    var hitCount = 0;
    var monsters = [Monster]();
    var bgMusicOn = false;
    var soundEffectOn = false;
    var timeLimiting = true;
    var animating = true;
    var infinityMode = false;
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timeRemain, forKey: GameInfoProperty.timeRemain);
        aCoder.encode(initMonsterCount, forKey: GameInfoProperty.initMonsterCount);
        aCoder.encode(hitCount, forKey: GameInfoProperty.hitCount);
        aCoder.encode(monsters, forKey: GameInfoProperty.monsters);
        aCoder.encode(bgMusicOn, forKey: GameInfoProperty.bgMusicOn);
        aCoder.encode(soundEffectOn, forKey: GameInfoProperty.soundEffectOn);
        aCoder.encode(timeLimiting, forKey: GameInfoProperty.timeLimiting);
        aCoder.encode(animating, forKey: GameInfoProperty.animating);
        aCoder.encode(infinityMode, forKey: GameInfoProperty.infinityMode);
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let timeRemain = aDecoder.decodeInteger(forKey: GameInfoProperty.timeRemain);
        let initMCnt = aDecoder.decodeInteger(forKey: GameInfoProperty.initMonsterCount);
        let hitCnt = aDecoder.decodeInteger(forKey: GameInfoProperty.hitCount);
        guard let monsters = aDecoder.decodeObject(forKey: GameInfoProperty.monsters) as? [Monster] else {
            return nil;
        }
        
        let bgMusicOn = aDecoder.decodeBool(forKey: GameInfoProperty.bgMusicOn);
        let soundEffectOn = aDecoder.decodeBool(forKey: GameInfoProperty.soundEffectOn);
        let timeLimiting = aDecoder.decodeBool(forKey: GameInfoProperty.timeLimiting);
        let animating = aDecoder.decodeBool(forKey: GameInfoProperty.animating);
        let inf = aDecoder.decodeBool(forKey: GameInfoProperty.infinityMode);
        
        self.init(timeRemain: timeRemain, initMonsterCount: initMCnt, hitCount: hitCnt, monsters: monsters, bgMusicOn: bgMusicOn, soundEffectOn: soundEffectOn, timeLimiting: timeLimiting, animating: animating, infinityMode: inf);
    }
    
    init(timeRemain: Int = 60,
         initMonsterCount: Int = 10,
         hitCount: Int = 0,
         monsters: [Monster] = [Monster](),
         bgMusicOn: Bool = false,
         soundEffectOn: Bool = false,
         timeLimiting: Bool = true,
         animating: Bool = true,
         infinityMode: Bool = false) {
        
        self.timeRemain = timeRemain;
        self.initMonsterCount = initMonsterCount;
        self.hitCount = hitCount;
        self.monsters = monsters;
        self.bgMusicOn = bgMusicOn;
        self.soundEffectOn = soundEffectOn;
        self.timeLimiting = timeLimiting;
        self.animating = animating;
        self.infinityMode = infinityMode;
    }
    
}
