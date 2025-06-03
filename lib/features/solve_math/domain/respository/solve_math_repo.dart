/*
TodoRepo is an abstract class that defines the methods that the TodoRepository class must implement.

Here we define what the app can do
*/

abstract class SolveMathRepo {
  Future<String> solveMath(dynamic imageInput);
}

/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
