# shade
A fast and flexible Microservice oriented HTTP server framework for dart.
## Dependency Injection
Shade has a buil-in flexible dependency injector. Using the `Injectable` annotation you can define the name of the constructor that is being injected into.
```dart
abstract class Service {
    ...
}

abstract class ImplementationOfService extends Service {
    ...
}

@Injectable()
@Controller()
class ExampleController {

    final Service service;

    const ExampleController(@Inject("TokenForService") this.service);

    @Get("/example")
    void getExample(State state, Request req, Response res, Step step) {
        ...
    }
}
```
## Routing
Routing in shade is simple and flexible. Enables the quick addition of endpoints.
```dart
@Controller("/someBasePath")
class ExampleController {
    ...

    @Get("/example")
    void getExample(State state, Request req, Response res, Step step) {
        ...
    }

    @Post("/:echoMessage") // Path parameter
    void getEcho(State state, Request req, Response res, Step step) {
        ...
    }

    @Get("/example/*") // Catch all
    void getEcho(State state, Request req, Response res, Step step) {
        ...
    }
}
```
## Middleware
Middleware is execution of Application level middleware -> Controller level middleware -> Route level middleware. On each of these levels middleware is executed in order of addition/annotation and determined to be executed before or after the endpoint by being annotated or added as `Preware` for before and `Postware` for after.

You can define Middleware to be a single function or as an instance of `Middleware`. Functional middleware is static where as instances of `Middleware` can have dependencies injected into them or can be instantiated manually when annotated or added with parameters.
### Functional Middleware
```dart
void middlewareFunc(State state, Request req, Response res, Step step) {
    state.putLocal("local", "some value for local.");
    step(); // Moves to next RouteStep
}
```
### Instance of Middleware
```dart
// Middleware as with dependency injection.
@Injectable()
class SomeMiddleware extends Middleware {

    final Service service;

    const SomeMiddleware(@Inject("TokenForService") this.service);

    @override
    void step(State state, Request req, Response res, Step step) {
        int someValue = this.service.calculate();
        state.putLocal("local", someValue);
        step(); // Moves to next RouteStep
    }
}

// Parameterized middleware.
class SomeOtherMiddleware extends Middleware {

    final String parameter;

    const SomeMiddleware(this.parameter);

    @override
    void step(State state, Request req, Response res, Step step) {
        state.putLocal("local", this.parameter);
        step(); // Moves to next RouteStep
    }
}
```
### Annotating and Adding Middleware
```dart

// Controller and Route level.
@Controller()
@Preware(middleware) // Execute middleware just before this all endpoints in this Controller
@Postware(SomeMiddleware) // Execute middleware right after all endpoints in this Controller
class ExampleController {

    @Get("/example")
    @Postware(SomeMiddleware) // Execute middleware right after this endpoint
    @Preware([middleware, SomeOtherMiddleware("someParameter")]) // Execute all middleware in order just before this endpoint
    void getExample(State state, Request req, Response res, Step step) {
        ...
    }

}

// Application level.
void main() {
    var appBuilder = ApplicationBuilder()
        ...
        ..addPreware(SomeOtherMiddlware("anotherParameter"))
        ..addPostware(middleware);
        ...
}
```
## Build an Application
Shade has an `ApplicationBuilder` class that allows you to add `Controllers`, set an `ErrorHandler`, add `Injections`, and add Application level `Middleware`.
### Building a simple Application.
```dart
void main() {

    var appBuilder = ApplicationBuilder()
        ..addAllInjections({
            "TokenForService": ImplementationOfService // Define types or instances of types for your injections
        })
        ..addPreware(SomeOtherMiddlware("anotherParameter")) // Execute before all endpoints in the application
        ..addPostware(SomeOtherApplicationMiddleware) // Execute after all endpoints in the application
        ..addAllControllers([
            ExampleController // list of all Controllers in the Application
        ]);

    var app = appBuilder.build();
    app.listen(8000, () => print("Listening on port 8000"));
}
```
## Examples
See an example in action [here](https://github.com/adam-soph/shade/tree/master/example).