//
//  SQPDatabase.h
//  SQPersist
//
//  Created by Christopher Ney on 30/10/2014.
//  Copyright (c) 2014 Christopher Ney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDB/FMDB.h>

/**
 *  Database manager.
 */
@interface SQPDatabase : NSObject {
    
    /**
     *  FMDB Database connector.
     */
    FMDatabase *_database;
    
    /**
     *  FMDB Database connector.
     */
    FMDatabaseQueue *_databaseQueue;
    
    /**
     *  Database name.
     */
    NSString *_dbName;
    
    /**
     *  Database filepath.
     */
    NSString *_dbPath;
    
    /**
     * Saves known properties of entities System.
     */
    NSMutableDictionary *_properties;

    /**
     * Saves known entities System.
     */
    NSMutableSet *_entities;
}

/**
 *  If enable to YES, the system will check and add missing columns into the database table.
 *  Warning : execute may queries. Please desactive this option after your tables updates.
 */
@property (nonatomic) BOOL addMissingColumns;

/**
 *  Indicate if the generated SQL requests are logged.
 */
@property (nonatomic) BOOL logRequests;

/**
 *  Indicate if the information of scanning properties are logged.
 */
@property (nonatomic) BOOL logPropertyScan;

/**
 *  The database queue connector
 */
@property (nonatomic, strong, readonly) FMDatabaseQueue *databaseQueue;

/**
 *  Get the main instance of the database manager.
 *
 *  @return Instance.
 */
+ (SQPDatabase*)sharedInstance;

#pragma mark - Manage Database

/**
 *  Setup the database.
 *
 *  @param dbName Name of the database.
 */
- (void)setupDatabaseWithName:(NSString*)dbName;

/**
 *  Return the name of the database.
 *
 *  @return Database name.
 */
- (NSString*)getDdName;

/**
 *  Return the path of the database.
 *
 *  @return Path of the database.
 */
- (NSString*)getDdPath;

/**
 *  Database connector.
 *
 *  @return Database connector.
 */
- (FMDatabase*)database;

/**
 *  Database queue connector.
 *
 *  @return Database queue connector.
 */
- (FMDatabaseQueue*)databaseQueue;

/**
 *  Check if the database file exists.
 *
 *  @return Return YES if the database exists.
 */
- (BOOL)databaseExists;

/**
 *  Remove the database.
 *
 *  @return Remove the database.
 */
- (BOOL)removeDatabase;

#pragma mark - Structure memorization

/**
 *  Remember scanned entity.
 *
 *  @param className  Entity class name
 *  @param properties Properties of entity.
 */
- (void)addScannedEntity:(NSString*)className andProperties:(NSArray*)properties;

/**
 *  Return YES if the entity is already scanned.
 *
 *  @param entity Entity class name
 *
 *  @return Return YES if the entity is already scanned.
 */
- (NSArray*)getExistingEntity:(NSString*)className;

/**
 *  Remember the the class is a entity system.
 *
 *  @param className Class name.
 */
- (void)addEntityObjectName:(NSString*)className;

/**
 *  Indique if a class name is know as an entity system.
 *
 *  @param className Class name.
 *
 *  @return Return YES if is an entity.
 */
- (BOOL)isEntityObject:(NSString*)className;

#pragma mark - Transactions

/**
 *  Begin a SQL Transaction.
 *
 *  @return Result of begin.
 */
- (BOOL)beginTransaction;

/**
 *  Commi a SQL Transaction.
 *
 *  @return Result of commit.
 */
- (BOOL)commitTransaction;

/**
 *  Rollback a SQL Transaction.
 *
 *  @return Result of rollback.
 */
- (BOOL)rollbackTransaction;


/////// Shortcut



@end

@interface SQPDatabase(FBDatabaseQueueCategory)

/** Synchronously perform database operations on queue.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDatabase:(__attribute__((noescape)) void (^)(FMDatabase *db))block;

/** Synchronously perform database operations on queue, using transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations on queue, using deferred transactions.
 
 @param block The code to be run on the queue of `FMDatabaseQueue`
 */

- (void)inDeferredTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;

@end

