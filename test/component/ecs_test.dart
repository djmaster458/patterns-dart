import 'package:patterns/patterns.dart';
import 'package:test/test.dart';

class _Position {
  final double x;
  _Position(this.x);
}

class _Velocity {
  final double x;
  _Velocity(this.x);
}

class _MovementSystem implements System {
  @override
  void update(World world, double deltaTime) {
    for (final entity in world.query([_Position, _Velocity])) {
      final position = world.getComponent<_Position>(entity)!;
      final velocity = world.getComponent<_Velocity>(entity)!;
      world.addComponent(
        entity,
        _Position(position.x + velocity.x * deltaTime),
      );
    }
  }
}

void main() {
  group('World', () {
    test('creates entities and stores typed components', () {
      final world = World();
      final entity = world.createEntity();
      final position = _Position(4.0);

      world.addComponent(entity, position);

      expect(world.entityCount, 1);
      expect(world.hasComponent<_Position>(entity), isTrue);
      expect(world.getComponent<_Position>(entity), same(position));
      expect(world.getComponent<_Velocity>(entity), isNull);
    });

    test('replaces and removes components', () {
      final world = World();
      final entity = world.createEntity();

      world
        ..addComponent(entity, _Position(1.0))
        ..addComponent(entity, _Position(2.0));

      expect(world.getComponent<_Position>(entity)!.x, 2.0);
      expect(world.removeComponent<_Position>(entity), isTrue);
      expect(world.removeComponent<_Position>(entity), isFalse);
      expect(world.hasComponent<_Position>(entity), isFalse);
    });

    test('queries entities with all requested component types', () {
      final world = World();
      final moving = world.createEntity();
      final stationary = world.createEntity();
      world
        ..addComponent(moving, _Position(0.0))
        ..addComponent(moving, _Velocity(1.0))
        ..addComponent(stationary, _Position(5.0));

      expect(world.query([_Position, _Velocity]), [moving]);
      expect(world.query([_Position]), [moving, stationary]);
      expect(world.query([]), [moving, stationary]);
    });

    test('destroying an entity removes it and its components', () {
      final world = World();
      final entity = world.createEntity();
      world.addComponent(entity, _Position(1.0));

      world.destroyEntity(entity);

      expect(world.entityCount, 0);
      expect(world.query([_Position]), isEmpty);
      expect(() => world.hasComponent<_Position>(entity), throwsArgumentError);
    });

    test('rejects entities from another world', () {
      final firstWorld = World();
      final secondWorld = World();
      final entity = firstWorld.createEntity();

      expect(
        () => secondWorld.addComponent(entity, _Position(1)),
        throwsArgumentError,
      );
    });

    test('updates systems with delta time', () {
      final world = World();
      final entity = world.createEntity();
      world
        ..addComponent(entity, _Position(2.0))
        ..addComponent(entity, _Velocity(3.0))
        ..addSystem(_MovementSystem());

      world.update(2);

      expect(world.getComponent<_Position>(entity)!.x, 8.0);
    });

    test('system registration is identity-based and removable', () {
      final world = World();
      final system = _MovementSystem();

      world
        ..addSystem(system)
        ..addSystem(system);

      expect(world.removeSystem(system), isTrue);
      expect(world.removeSystem(system), isFalse);
    });
  });
}
