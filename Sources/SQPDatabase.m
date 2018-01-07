//
//  SQPDatabase.m
//  SQPersist
//
//  Created by Christopher Ney on 29/10/2014.
//  Copyright (c) 2014 Christopher Ney. All rights reserved.
//

#import "SQPDatabase.h"

#define kSQPDefaultDdName @"SQPersist.db"

@interface SQPDatabase ()
- (FMDatabaseQueue*)createDatabaseQueue;
@end

/**
 *  Database manager.
 */
@implementation SQPDatabase

/**
 *  Get the main instance of the database manager.
 *
 *  @return Instance.
 */
+ (SQPDatabase*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark - Manage Database

/**
 *  Setup the database.
 *
 *  @param dbName Name of the database.
 */
- (void)setupDatabaseWithName:(NSString*)dbName {
 
    _dbName = dbName;
    _databaseQueue = [self createDatabaseQueue];
}

/**
 *  Return the name of the database.
 *
 *  @return Database name.
 */
- (NSString*)getDdName {
    
    if (_dbName == nil) [self createDatabaseQueue];
    return _dbName;
}

/**
 *  Return the path of the database.
 *
 *  @return Path of the database.
 */
- (NSString*)getDdPath {
     if (_dbPath == nil) [self createDatabaseQueue];
    return _dbPath;
}

/**
 *  Create the local SQLite database file (private method).
 *
 *  @return Database connector.
 */
- (FMDatabase*)createDatabase {
    
    if (_dbName == nil) _dbName = kSQPDefaultDdName;
    
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    _dbPath = [documentdir stringByAppendingPathComponent:_dbName];
    
    //NSLog(@"%@", _dbPath);
    
    _database = [FMDatabase databaseWithPath:_dbPath];
    _database.logsErrors = YES;
    _database.traceExecution = NO;
    
    if (![_database open]) {
        return nil;
    } else {
        return _database;
    }
}

/**
 *  Create the local SQLite database file (private method).
 *
 *  @return Database connector.
 */
- (FMDatabaseQueue*)createDatabaseQueue {
    
    if (_dbName == nil) _dbName = kSQPDefaultDdName;
    
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    _dbPath = [documentdir stringByAppendingPathComponent:_dbName];
    
    //NSLog(@"%@", _dbPath);
    
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_dbPath];
    
    return _databaseQueue;
}


/**
 *  Database connector.
 *
 *  @return Database connector.
 */
- (FMDatabase*)database {
    
    return _database;
}

/**
 *  Check if the database file exists.
 *
 *  @return Return YES if the database exists.
 */
- (BOOL)databaseExists {
 
    if (_dbPath != nil) {
        BOOL isDirectory = NO;
        return [[NSFileManager defaultManager] fileExistsAtPath:_dbPath isDirectory:&isDirectory];
    } else {
        return NO;
    }
}

/**
 *  Remove the database.
 *
 *  @return Remove the database.
 */
- (BOOL)removeDatabase {
    
    if (_dbPath != nil) {
        
        if (_databaseQueue != nil) {
            [_databaseQueue close];
        }
        
        NSError *error = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:_dbPath error:&error];
        
        if (error == nil) {
            _databaseQueue = nil;
            return YES;
        } else {
            NSLog(@"%@", [error localizedDescription]);
            return NO;
        }
        
    } else {
        return NO;
    }
}

#pragma mark - Structure memorization

/**
 *  Remember scanned entity.
 *
 *  @param className  Entity class name
 *  @param properties Properties of entity.
 */
- (void)addScannedEntity:(NSString*)className andProperties:(NSArray*)properties {
    
    if (_properties == nil) _properties = [[NSMutableDictionary alloc] init];
    
    if (className != nil && properties != nil) {
        
        if ([self getExistingEntity:className] == nil) {
            [_properties setObject:properties forKey:className];
        }
    }
}

/**
 *  Return YES if the entity is already scanned.
 *
 *  @param entity Entity class name
 *
 *  @return Return YES if the entity is already scanned.
 */
- (NSArray*)getExistingEntity:(NSString*)className {
    
    if (_properties != nil && className != nil) {
        NSArray *properties = (NSArray*)[_properties valueForKey:className];
        return properties;
    } else {
        return nil;
    }
}

/**
 *  Remember the the class is a entity system.
 *
 *  @param className Class name.
 */
- (void)addEntityObjectName:(NSString*)className {
    
    if (_entities == nil) _entities = [[NSMutableSet alloc] init];
    
    if (className != nil) {
        if ([self isEntityObject:className] == NO) {
            [_entities addObject:className];
        }
    }
}

/**
 *  Indique if a class name is know as an entity system.
 *
 *  @param className Class name.
 *
 *  @return Return YES if is an entity.
 */
- (BOOL)isEntityObject:(NSString*)className {
    
    if (_entities != nil && className != nil) {
        return [_entities containsObject:className];
    } else {
        return NO;
    }
}

#pragma mark - Transactions

/**
 *  Begin a SQL Transaction.
 *
 *  @return Result of begin.
 */
- (BOOL)beginTransaction {

    return NO;
}

/**
 *  Commi a SQL Transaction.
 *
 *  @return Result of commit.
 */
- (BOOL)commitTransaction {
    
    return NO;
}

/**
 *  Rollback a SQL Transaction.
 *
 *  @return Result of rollback.
 */
- (BOOL)rollbackTransaction {
    
    return NO;
}

@end
@implementation SQPDatabase(FBDatabaseQueueCategory)

/** Synchronously perform database operations on queue.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDatabase:(__attribute__((noescape)) void (^)(FMDatabase *db))block
{
    if(_databaseQueue == nil){
        [self createDatabaseQueue];
    }
    [self.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        _database = db;
        
        block(db);
        
        _database = nil;
    }];
}

/** Synchronously perform database operations on queue, using transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block
{
    if(_databaseQueue == nil){
        [self createDatabaseQueue];
    }
    [self.databaseQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        _database = db;
        
        block(db, rollback);
        
        _database = nil;
    }];
}

/** Synchronously perform database operations on queue, using deferred transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDeferredTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block
{
    if(_databaseQueue == nil){
        [self createDatabaseQueue];
    }
    [self.databaseQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        _database = db;
        
        block(db, rollback);
        
        _database = nil;
    }];
}

@end
