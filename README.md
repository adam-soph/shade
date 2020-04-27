# shade
 A fast and flexible Microservice oriented HTTP Server framework for dart.

## Routing
Routing in shade is simple and flexible. Enables the quick addition of endpoints
```dart
@Controller("/someBasePath")
class ExampleController {
    ...

    @Get("/example")
    void getExample(State state, Request req, Response res, Step step) {
        res.sendJson({
            "message": "Here's an example."
        });
        step();
    }

    @Post("/:echoMessage") // Path parameter
    void getEcho(State state, Request req, Response res, Step step) {
        res.sendJson({
            "message": req.getPathParameter("echoMessage")
        });
        step();
    }
}
```
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
        res.sendJson({
            "message": "Here's an example."
        });
        this.service.someFunction();
        step();
    }
    ...
}
```
## Middleware
You can define Middleware to be a single function or as an instance of middleware. Functional middleware is static where as instances of middleware can have dependencies injected into them or can be instantiated manually when annotated or added at the Application level. 
### Functional Middleware
```dart
void middleware(State state, Request req, Response res, Step step) {
    state.putLocal("local", "some value for local.");
    step();
}
```
### Instance of Middleware
```dart
@Injectable()
class SomeMiddleware extends Middleware {

    final Service service;

    const SomeMiddleware(@Inject("TokenForService") this.service);

    @override
    void step(State state, Request req, Response res, Step step) {
        state.putLocal("local", "some value for a local.");
        step();
    }
}

class SomeOtherMiddleware extends Middleware {

    final String parameter;

    const SomeMiddleware(this.parameter);

    @override
    void step(State state, Request req, Response res, Step step) {
        state.putLocal("local", "some value for a local.");
        step();
    }
}

```
### Annotating Middleware
```dart
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

    ...

}
```
## Build an Application
Shade has an `ApplicationBuilder` class that allows you to add Controllers, set an ErrorHandler, add Injections, and add Application wide middleware.
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
See more examples in the "examples" directory.