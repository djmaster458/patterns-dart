/// An entity created and owned by a [World].
final class Entity {
  Entity._(this.id);

  /// The entity's identifier within its world.
  final int id;

  @override
  String toString() => 'Entity($id)';
}

/// A system that updates entities and their components in a [World].
abstract interface class System {
  /// Updates this system. [deltaTime] is elapsed time in seconds.
  void update(World world, double deltaTime);
}

/// Stores entities, their components, and systems that update them.
class World {
  final Set<Entity> _entities = {};
  final Map<Type, Map<Entity, Object>> _components = {};
  final List<System> _systems = [];
  int _nextEntityId = 0;

  /// The number of entities currently in this world.
  int get entityCount => _entities.length;

  /// Creates an empty entity in this world.
  Entity createEntity() {
    final entity = Entity._(_nextEntityId++);
    _entities.add(entity);
    return entity;
  }

  /// Destroys [entity] and removes all its components.
  void destroyEntity(Entity entity) {
    _requireEntity(entity);
    _entities.remove(entity);
    for (final components in _components.values) {
      components.remove(entity);
    }
  }

  /// Adds or replaces a component of type [T] on [entity].
  void addComponent<T extends Object>(Entity entity, T component) {
    _requireEntity(entity);
    _components.putIfAbsent(T, () => {})[entity] = component;
  }

  /// Gets the component of type [T] on [entity], or `null` if absent.
  T? getComponent<T extends Object>(Entity entity) {
    _requireEntity(entity);
    return _components[T]?[entity] as T?;
  }

  /// Whether [entity] has a component of type [T].
  bool hasComponent<T extends Object>(Entity entity) {
    _requireEntity(entity);
    return _components[T]?.containsKey(entity) ?? false;
  }

  /// Removes the component of type [T] from [entity].
  ///
  /// Returns `true` if a component was removed.
  bool removeComponent<T extends Object>(Entity entity) {
    _requireEntity(entity);
    return _components[T]?.remove(entity) != null;
  }

  /// Returns a snapshot of entities that have every requested component type.
  ///
  /// With no component types, returns all entities.
  List<Entity> query(Iterable<Type> componentTypes) {
    final componentMaps = <Map<Entity, Object>>[];
    for (final type in componentTypes) {
      final components = _components[type];
      if (components == null) return [];
      componentMaps.add(components);
    }

    return _entities
        .where(
          (entity) => componentMaps.every(
            (components) => components.containsKey(entity),
          ),
        )
        .toList();
  }

  /// Adds [system] to this world. The same instance is added only once.
  void addSystem(System system) {
    if (_systems.any((registered) => identical(registered, system))) return;
    _systems.add(system);
  }

  /// Removes [system] from this world, returning whether it was registered.
  bool removeSystem(System system) {
    final index = _systems.indexWhere(
      (registered) => identical(registered, system),
    );
    if (index == -1) return false;
    _systems.removeAt(index);
    return true;
  }

  /// Updates the systems registered at the start of this call.
  ///
  /// Systems added or removed during an update take effect on the next call.
  void update(double deltaTime) {
    for (final system in List<System>.of(_systems)) {
      system.update(this, deltaTime);
    }
  }

  void _requireEntity(Entity entity) {
    if (!_entities.contains(entity)) {
      throw ArgumentError.value(
        entity,
        'entity',
        'Entity is not in this world.',
      );
    }
  }
}
