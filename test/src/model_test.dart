part of guinness_test;

testModel(){
  group("[model]", (){
    group("[It]", (){
      test("returns all before each functions", (){
        final outerBeforeEach = new guinness.BeforeEach(noop, priority: 0);
        final outer = createDescribe()..addBeforeEach(outerBeforeEach);

        final innerBeforeEach = new guinness.BeforeEach(noop, priority: 0);
        final inner = createDescribe(parent: outer)..addBeforeEach(innerBeforeEach);

        final it = createIt(parent: inner);

        expect(it.beforeEachFns, equals([outerBeforeEach, innerBeforeEach]));
      });

      test("returns all after each functions", (){
        final outerAfterEach = new guinness.AfterEach(noop, priority: 0);
        final outer = createDescribe()..addAfterEach(outerAfterEach);

        final innerAfterEach = new guinness.AfterEach(noop, priority: 0);
        final inner = createDescribe(parent: outer)..addAfterEach(innerAfterEach);

        final it = createIt(parent: inner);

        expect(it.afterEachFns, equals([innerAfterEach, outerAfterEach]));
      });

      test("sorts all beforeEach fns by priority", (){
        final beforeEach1 = new guinness.BeforeEach(noop, priority: 0);
        final beforeEach2 = new guinness.BeforeEach(noop, priority: 1);

        final describe = createDescribe()
          ..addBeforeEach(beforeEach1)
          ..addBeforeEach(beforeEach2);

        final it = createIt(parent: describe);

        expect(it.beforeEachFns, equals([beforeEach2, beforeEach1]));
      });

      test("sorts all afterEach fns by priority", (){
        final afterEach1 = new guinness.AfterEach(noop, priority: 0);
        final afterEach2 = new guinness.AfterEach(noop, priority: 1);

        final describe = createDescribe()
          ..addAfterEach(afterEach1)
          ..addAfterEach(afterEach2);

        final it = createIt(parent: describe);

        expect(it.afterEachFns, equals([afterEach2, afterEach1]));
      });

      test("runs async beforeEach callbacks in order", () {
        final log = [];

        createBeforeEach(delay, message) {
          var func = () => new Future.delayed(new Duration(milliseconds: delay), () => log.add(message));
          return new guinness.BeforeEach(func, priority: 1);
        }

        final beforeEach1 = createBeforeEach(2, "one");
        final beforeEach2 = createBeforeEach(1, "two");

        final describe = createDescribe()
          ..addBeforeEach(beforeEach1)
          ..addBeforeEach(beforeEach2);

        final it = createIt(parent: describe);

        it.withSetupAndTeardown().then(expectAsync((_) {
          expect(log, equals(["one", "two"]));
        }));
      });

      test("runs async afterEach callbacks in order", () {
        final log = [];

        createAfterEach(delay, message) {
          var func = () => new Future.delayed(new Duration(milliseconds: delay), () => log.add(message));
          return new guinness.AfterEach(func, priority: 1);
        }

        final afterEach1 = createAfterEach(2, "one");
        final afterEach2 = createAfterEach(1, "two");

        final describe = createDescribe()
          ..addAfterEach(afterEach1)
          ..addAfterEach(afterEach2);

        final it = createIt(parent: describe);

        it.withSetupAndTeardown().then(expectAsync((_) {
          expect(log, equals(["one", "two"]));
        }));
      });

      test("does not run afterEach callbacks if beforeEach callbacks errored", () {
        final be = new guinness.BeforeEach(() => throw "BOOM", priority: 1);

        var run = false;
        final ae = new guinness.AfterEach(() => run = true, priority: 1);

        final describe = createDescribe()
          ..addBeforeEach(be)
          ..addAfterEach(ae);

        final it = createIt(parent: describe);

        it.withSetupAndTeardown().catchError(expectAsync((_) {
          expect(run, isFalse);
        }));
      });
    });
  });
}