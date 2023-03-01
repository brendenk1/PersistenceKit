# Using PersistenceManager

The persistence manager provides the API necessary to perform CRUD operations with persisted objects.

## Overview

### Instantiation of the Manager

To create an instance, the manager needs two items at a minimum, the name of a CoreData model file to use and the file location of the model file. A flag can indicate if the store is persisted in memory.

```
let manager = PersistenceManager(
    name: #modelname#,
    modelLocation: #location#,
    inMemory: #optional flag#
)
```

### Interactions with objects

Performing CRUD operations are straightforward, as the manager instance provides an API for creating, deleting, reading, and updating.

* Creating an object: 

```
try manager.create(type: #some object type#) { newObject in
    // configure object properties here
}
```

* Updating an object: 

```
let updated = try await manager.update(#some object#) { object in
    // perform updates to properties here
}
```

* Deleting an object:

```
try manager.delete(item: #some object#)
```

* Reading objects:

```
try await manager.read(itemType: #some object type#, sort: #some sort descriptor#)
```

In addition to simply reading out objects, limits, and predicates can be provided to the manager individually or together.

```
let objects = try await manager.read(
    itemType: Test.self,
    sort: SortDescriptor(\.date),
    limit: 1,
    predicate: predicate
)
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
